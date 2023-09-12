##################################################  Set Parameters ##################################################
export vpc_stack_name=eks-vpc-stack
export cluster_name=cli-cluster2
export repo_name=springboot-repo
export postgres_name=springboot-postgres
export region=us-west-1

# Running through this workshop: https://archive.eksworkshop.com/beginner/115_sg-per-pod/10_secgroup/
# Really hard to redo because of cloudformation stacks don't get deleted :/ 
eksctl create cluster --name $cluster_name --region $region --version 1.27 --without-nodegroup

export VPC_ID=$(aws eks describe-cluster \
    --name $cluster_name \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)


SUBNET_IDS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "Subnets[*].SubnetId" \
    --output text| tr '\t' ',')

export PRIVATE_SUBNETS_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-$cluster_name-cluster/SubnetPrivate*" \
    --query 'Subnets[*].SubnetId' \
    --output text| tr '\t' ',')

eksctl create nodegroup \
  --cluster $cluster_name \
  --region $region \
  --name my-nodegroup \
  --node-type m5.large \
  --nodes 3 \
  --nodes-min 2 \
  --node-private-networking \
  --nodes-max 4 \
  --subnet-ids $PRIVATE_SUBNETS_ID 

aws eks update-kubeconfig --name $cluster_name --region $region

aws ec2 create-security-group \
    --description 'RDS SG' \
    --group-name 'RDS_SG' \
    --vpc-id ${VPC_ID}

export RDS_SG=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=RDS_SG Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" --output text)

export NODE_GROUP_SG=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=eks-cluster-sg-$cluster_name-*" "Name=vpc-id,Values=${VPC_ID}" --query "SecurityGroups[*].GroupId" --output text)

# Allow POD_SG to connect to the RDS
aws ec2 authorize-security-group-ingress \
    --group-id ${RDS_SG} \
    --protocol tcp \
    --port 5432 \
    --source-group ${NODE_GROUP_SG}


export PRIVATE_SUBNETS_ID_JSON=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-$cluster_name-cluster/SubnetPrivate*" \
    --query 'Subnets[*].SubnetId' \
     --output json | jq -c .)

# create a db subnet group
aws rds create-db-subnet-group \
    --db-subnet-group-name rds-subnet-group \
    --db-subnet-group-description rds-subnet-group \
    --subnet-ids ${PRIVATE_SUBNETS_ID_JSON}

export postgresPassword=$(aws secretsmanager get-secret-value --secret-id "postgres-credentials" --query 'SecretString' --output text | jq -r '.password')

aws rds create-db-instance \
    --engine postgres \
    --db-instance-identifier $postgres_name \
    --allocated-storage 100 \
    --db-instance-class db.t3.micro	 \
    --master-username postgres \
    --master-user-password $postgresPassword \
    --db-name demo \
    --db-subnet-group-name rds-subnet-group \
    --vpc-security-group-ids $RDS_SG \
    --no-publicly-accessible

kubectl create secret generic rds\
    --namespace=default \
    --from-literal="password=${postgresPassword}" \

# Check status 
aws rds describe-db-instances \
    --db-instance-identifier $postgres_name  \
    --query "DBInstances[].DBInstanceStatus" \
    --output text

export RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier $postgres_name\
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

##################################################  Create Container Regisry  ##################################################
# Create the artifact registry and push build: https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html
# This youtube video was helpful too: https://www.youtube.com/watch?v=vWSRWpOPHws&t=354s
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin 948243776115.dkr.ecr.$region.amazonaws.com #4.95s
aws ecr create-repository \
    --repository-name $repo_name \
    --image-scanning-configuration scanOnPush=true \
    --region $region #.89s

docker buildx build --platform=linux/amd64 -t 948243776115.dkr.ecr.$region.amazonaws.com/$repo_name . #3.76s
docker push 948243776115.dkr.ecr.$region.amazonaws.com/$repo_name #101.93s

##################################################  Installing Ingress controller  ##################################################
# Configuring add ons necessary to install aws load balancer controller following: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
# Creating an IAM OIDC provider
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve #2.2435s

# Configuring the Amazon VPC CNI plugin for Kubernetes to use IAM
eksctl create iamserviceaccount \
    --name aws-node2 \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name AmazonEKSVPCCNIRole-$cluster_name \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --override-existing-serviceaccounts \
    --approve # 32.0906s

CNIRoleARN=$(aws iam get-role --role-name "AmazonEKSVPCCNIRole-$cluster_name" --query 'Role.Arn' --output text) #1s

# Adding necessary add ons
aws eks create-addon --cluster-name $cluster_name --addon-name vpc-cni --addon-version v1.13.2-eksbuild.1 \
    --service-account-role-arn $CNIRoleARN #1s

aws eks create-addon --cluster-name $cluster_name --addon-name coredns --addon-version v1.9.3-eksbuild.3 #1s

KubeProxy=$(kubectl describe daemonset kube-proxy -n kube-system | awk '/Image:/ {print $2}') #1s

kubectl set image daemonset.apps/kube-proxy -n kube-system kube-proxy=$KubeProxy #1s

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json #.6

LBControlerPolicyARN=$(aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json --query 'Policy.Arn' --output text) #1s

eksctl create iamserviceaccount \
  --cluster=$cluster_name \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=$LBControlerPolicyARN \
  --approve #32.3763s

helm repo add eks https://aws.github.io/eks-charts #1s

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$cluster_name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller #3.63

##################################################  Creating deployment with ingress ##################################################
# TODO: Need to update image to include the repo url: 948243776115.dkr.ecr.us-west-1.amazonaws.com/$repo_name
kubectl apply -f CLI/aws.yaml #1m 40s


















##################################################  Create EKS Cluster  ##################################################
# Following this guide to create VPC: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html
aws cloudformation create-stack \
  --region $region \
  --stack-name  $vpc_stack_name \
  --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml #2m 35s

SubnetIDs=$(aws ec2 describe-subnets --filters "Name=tag:aws:cloudformation:logical-id,Values=PrivateSubnet02,PrivateSubnet01" "Name=tag:aws:cloudformation:stack-name,Values=$vpc_stack_name" \
--query "Subnets[].SubnetId" --output text| tr -s '\t' ',' ) #1.2s
eksctl create cluster --name $cluster_name --region $region --version 1.27 --vpc-private-subnets $SubnetIDs --without-nodegroup #668.6614s

eksctl create nodegroup \
  --cluster $cluster_name \
  --region $region \
  --name my-nodegroup \
  --node-type m5.medium \
  --nodes 3 \
  --nodes-min 2 \
  --node-private-networking \
  --nodes-max 4 \
--subnet-ids $SubnetIDs #136.2s

aws eks update-kubeconfig --name terraform-cluster --region eu-west-1


##################################################  Create Postgres  ##################################################
aws rds create-db-instance \
    --engine postgres \
    --db-instance-identifier $postgres_name \
    --allocated-storage 100 \
    --db-instance-class db.t3.micro	 \
    --master-username postgres \
    --master-user-password Sup3rS3cret! # 4min (returns quickly, but creating in background)

####### update VPCSecurityGroupID to allow connection from anywhere ########
VpcSgID=$(aws rds describe-db-instances \
    --filters Name=db-instance-id,Values=$postgres_name \
    --query 'DBInstances[*].[VpcSecurityGroups[0].VpcSecurityGroupId]' --output text) #.78s

# If you want to look at security group first, run: aws ec2 describe-security-groups --group-ids $VpcSgID
aws ec2 authorize-security-group-ingress --group-id $VpcSgID --protocol tcp --port 5432 --cidr 0.0.0.0/0 #1.16

# TODO:Get endpoint and update the application.properties file in code .... this will take some time
aws rds describe-db-instances \
    --query 'DBInstances[*].[Endpoint.Address]' \
    --filters Name=db-instance-id,Values=$postgres_name \
    --output text #.77s





    # Hitting an error and not sure what the IAM Role needs to be. Overall I've hit a bunch of bugs in this script with weird naming conventions that they're using. For example they don't go over the cluster creation, but reference the cluster name multiple times. I tried finding the cluster name in the resource itself but couldn't find it useful.
    # I'm going to swap tactics and try deploying the rest of this app as usual and see if it works as is since the RDS is private now and should be connected to my instance already
    eksctl get nodegroup --cluster=$cluster_name --name=my-nodegroup -o yaml

    aws eks describe-nodegroup --cluster-name $cluster_name --nodegroup-name my-nodegroup

    aws iam attach-role-policy \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController \
        --role-name EKSVPCResourceControllerRole
