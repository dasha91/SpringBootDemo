##################################################  Set Parameters ##################################################
export vpc_stack_name=eks-vpc-stack
export cluster_name=cli-cluster
export repo_name=springboot-repo
export postgres_name=springboot-postgres
export region=us-west-1

Sup3rS3cret!
##################################################  Create EKS Cluster (12m 52.863s)  ##################################################

# First followed this guide which used cloudformation, which was a bad experience. Unclear what was created and 
# cloudformation is difficult to work with generally (errors are cryptic, isn't idempotenet, takes a long time to deploy: 
# https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html

# Running through this workshop: https://archive.eksworkshop.com/beginner/115_sg-per-pod/10_secgroup/
# Really hard to redo because of cloudformation stacks don't get deleted :/ 
# Hitting an error and not sure what the IAM Role needs to be. Overall I've hit a bunch of bugs in this script with weird naming conventions that they're using. For example they don't go over the cluster creation, but reference the cluster name multiple times. I tried finding the cluster name in the resource itself but couldn't find it useful.
# I'm going to swap tactics and try deploying the rest of this app as usual and see if it works as is since the RDS is private now and should be connected to my instance already
    # eksctl get nodegroup --cluster=$cluster_name --name=my-nodegroup -o yaml

    # aws eks describe-nodegroup --cluster-name $cluster_name --nodegroup-name my-nodegroup

    # aws iam attach-role-policy \
    #     --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController \
    #     --role-name EKSVPCResourceControllerRole
#606.6089s
eksctl create cluster --name $cluster_name --region $region --version 1.27 --without-nodegroup | gnomon

# 1.1595s
export VPC_ID=$(aws eks describe-cluster \
    --name $cluster_name \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text) | gnomon

# 1.8384s
export PRIVATE_SUBNETS_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-$cluster_name-cluster/SubnetPrivate*" \
    --query 'Subnets[*].SubnetId' \
    --output text| tr '\t' ',') | gnomon
# 161.6282s
eksctl create nodegroup \
  --cluster $cluster_name \
  --region $region \
  --name my-nodegroup \
  --node-type m5.large \
  --nodes 3 \
  --nodes-min 2 \
  --node-private-networking \
  --nodes-max 4 \
  --subnet-ids $PRIVATE_SUBNETS_ID | gnomon

#1.6280s
aws eks update-kubeconfig --name $cluster_name --region $region | gnomon

##################################################  Create Container Regisry (1m 50.7551s)  ##################################################
# Create the artifact registry and push build: https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html
# This youtube video was helpful too: https://www.youtube.com/watch?v=vWSRWpOPHws&t=354s
# 9.1827s
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin 948243776115.dkr.ecr.$region.amazonaws.com | gnomon
# 0.9925s
aws ecr create-repository \
    --repository-name $repo_name \
    --image-scanning-configuration scanOnPush=true \
    --region $region | gnomon

#2.7299s
docker buildx build --platform=linux/amd64 -t 948243776115.dkr.ecr.$region.amazonaws.com/$repo_name .  | gnomon
# 97.8500s
docker push 948243776115.dkr.ecr.$region.amazonaws.com/$repo_name  | gnomon

##################################################  Create Postgres (6m 13.1066s) ##################################################
# 1.7224s
aws ec2 create-security-group \
    --description 'RDS SG' \
    --group-name 'RDS_SG' \
    --vpc-id ${VPC_ID} | gnomon

# 0.9458s
export RDS_SG=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=RDS_SG Name=vpc-id,Values=${VPC_ID} \
    --query "SecurityGroups[0].GroupId" --output text) | gnomon

# 0.8975s
export NODE_GROUP_SG=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=eks-cluster-sg-$cluster_name-*" "Name=vpc-id,Values=${VPC_ID}" \
  --query "SecurityGroups[*].GroupId" --output text) | gnomon

# Allow POD_SG to connect to the RDS 
# 0.9628s
aws ec2 authorize-security-group-ingress \
    --group-id ${RDS_SG} \
    --protocol tcp \
    --port 5432 \
    --source-group ${NODE_GROUP_SG} | gnomon

# 0.8199s
export PRIVATE_SUBNETS_ID_JSON=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=eksctl-$cluster_name-cluster/SubnetPrivate*" \
    --query 'Subnets[*].SubnetId' \
     --output json | jq -c .) | gnomon

# create a db subnet group
#1.1506s
aws rds create-db-subnet-group \
    --db-subnet-group-name rds-subnet-group \
    --db-subnet-group-description rds-subnet-group \
    --subnet-ids ${PRIVATE_SUBNETS_ID_JSON} | gnomon

# 0.9863s
export postgresPassword=$(aws secretsmanager get-secret-value --secret-id "postgres-credentials" \
  --query 'SecretString' --output text | jq -r '.password') | gnomon

# 1.8444s: + 6m to become availalbe
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
    --no-publicly-accessible | gnomon

  # Check status 
  aws rds describe-db-instances \
      --db-instance-identifier $postgres_name  \
      --query "DBInstances[].DBInstanceStatus" \
      --output text | gnomon
# 2.6037s
kubectl create secret generic rds\
    --namespace=default \
    --from-literal="password=${postgresPassword}" | gnomon

# TODO:Get endpoint and update the application.properties file in code .... this will take some time
# 1.1732s
export RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier $postgres_name\
    --query 'DBInstances[0].Endpoint.Address' \
    --output text) | gnomon

##################################################  Installing Ingress controller (1m 26.3481s)  ##################################################
# Configuring add ons necessary to install aws load balancer controller following: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
# Creating an IAM OIDC provider
# 1.9715s
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve | gnomon

# Configuring the Amazon VPC CNI plugin for Kubernetes to use IAM
# 32.4674s
eksctl create iamserviceaccount \
    --name aws-node2 \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name AmazonEKSVPCCNIRole-$cluster_name \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --override-existing-serviceaccounts \
    --approve | gnomon

# 1.5137s
CNIRoleARN=$(aws iam get-role --role-name "AmazonEKSVPCCNIRole-$cluster_name" --query 'Role.Arn' --output text) | gnomon

# Adding necessary add ons
# 1.7278s
aws eks create-addon --cluster-name $cluster_name --addon-name vpc-cni --addon-version v1.13.2-eksbuild.1 \
    --service-account-role-arn $CNIRoleARN | gnomon

# 1.4145s
aws eks create-addon --cluster-name $cluster_name --addon-name coredns --addon-version v1.9.3-eksbuild.3 | gnomon

# 2.4102s
KubeProxy=$(kubectl describe daemonset kube-proxy -n kube-system | awk '/Image:/ {print $2}') | gnomon

# 2.0758s
kubectl set image daemonset.apps/kube-proxy -n kube-system kube-proxy=$KubeProxy | gnomon

# 0.5749s
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json | gnomon

# 1.5343s
LBControlerPolicyARN=$(aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json --query 'Policy.Arn' --output text) | gnomon

#33.6575s
eksctl create iamserviceaccount \
  --cluster=$cluster_name \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=$LBControlerPolicyARN \
  --approve | gnomon

# 0.2567s
helm repo add eks https://aws.github.io/eks-charts | gnomon

# 6.7438s
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$cluster_name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller | gnomon

##################################################  Creating deployment with ingress (2m 28.133s) ##################################################
# TODO: Need to update image to include the repo url: 948243776115.dkr.ecr.us-west-1.amazonaws.com/$repo_name
# 3.8133s + 2m25s until ingress connects
kubectl apply -f CLI/aws.yaml | gnomon 
