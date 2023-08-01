##################################################  INSTALL PREREQUISITES ##################################################
# Set up a docker account 
brew install eksctl

# Install AWS: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
# Enable the following APIs: Artifact Registry, Kubernetes Engine API


##################################################  Set variable names ##################################################
export vpc_stack_name=eks-vpc-stack2
export cluster_name=spring-boot-demo-cluster2
export repo_name=springboot-repo
export postgres_name=springboot-postgres

##################################################  Create VPC  ##################################################
# Following this guide to create VPC: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html
aws cloudformation create-stack \
  --region us-west-1 \
  --stack-name  $vpc_stack_name \
  --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml

SubnetIDs=$(aws ec2 describe-subnets --filters "Name=tag:aws:cloudformation:logical-id,Values=PrivateSubnet02,PrivateSubnet01" "Name=tag:aws:cloudformation:stack-name,Values=$vpc_stack_name" \
--query "Subnets[].SubnetId" --output text| tr -s '\t' ',' )

##################################################  Create EKS Cluster  ##################################################
# Creating the cluster 
eksctl create cluster --name $cluster_name --region us-west-1 --version 1.27 --vpc-private-subnets $SubnetIDs --without-nodegroup

eksctl create nodegroup \
  --cluster $cluster_name \
  --region us-west-1 \
  --name my-nodegroup \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 2 \
  --node-private-networking \
  --nodes-max 4 \
 --subnet-ids $SubnetIDs

###### Configuring add ons necessary to install aws load balancer controller ########
# Following: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
#Creating an IAM OIDC provider
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve 

# Configuring the Amazon VPC CNI plugin for Kubernetes to use IAM
eksctl create iamserviceaccount \
    --name aws-node2 \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name AmazonEKSVPCCNIRole-$cluster_name \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --override-existing-serviceaccounts \
    --approve

CNIRoleARN=$(aws iam get-role --role-name "AmazonEKSVPCCNIRole-$cluster_name" --query 'Role.Arn' --output text)

# Adding necessary add ons
aws eks create-addon --cluster-name $cluster_name --addon-name vpc-cni --addon-version v1.13.2-eksbuild.1 \
    --service-account-role-arn $CNIRoleARN

aws eks create-addon --cluster-name $cluster_name --addon-name coredns --addon-version v1.9.3-eksbuild.3

KubeProxy=$(kubectl describe daemonset kube-proxy -n kube-system | awk '/Image:/ {print $2}')  

kubectl set image daemonset.apps/kube-proxy -n kube-system kube-proxy=$KubeProxy

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json

LBControlerPolicyARN=$(aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy5 \
    --policy-document file://iam_policy.json --query 'Policy.Arn' --output text)

eksctl create iamserviceaccount \
  --cluster=$cluster_name \
  --namespace=kube-system \
  --name=aws-load-balancer-controller2 \
  --role-name AmazonEKSLoadBalancerControllerRole2 \
  --attach-policy-arn=$LBControlerPolicyARN \
  --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$cluster_name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller2 

##################################################  Create Postgres  ##################################################
aws rds create-db-instance \
    --engine postgres \
    --db-instance-identifier $postgres_name \
    --allocated-storage 100 \
    --db-instance-class db.t3.micro	 \
    --master-username postgres \
    --master-user-password Sup3rS3cret!

####### update VPCSecurityGroupID to allow connection from anywhere ########
VpcSgID=$(aws rds describe-db-instances \
    --filters Name=db-instance-id,Values=$postgres_name \
    --query 'DBInstances[*].[VpcSecurityGroups[0].VpcSecurityGroupId]' --output text)

# If you want to look at security group first, run: aws ec2 describe-security-groups --group-ids $VpcSgID
aws ec2 authorize-security-group-ingress --group-id $VpcSgID --protocol tcp --port 5432 --cidr 0.0.0.0/0

####### Get endpoint and update the application.properties file in code .... this will take some time
aws rds describe-db-instances \
    --query 'DBInstances[*].[Endpoint.Address]' \
    --filters Name=db-instance-id,Values=$postgres_name \
    --output text
##################################################  Create repo and deploy  ##################################################
# Create the artifact registry and push build: https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html
# This youtube video was helpful too: https://www.youtube.com/watch?v=vWSRWpOPHws&t=354s
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 948243776115.dkr.ecr.us-west-1.amazonaws.com
aws ecr create-repository \
    --repository-name $repo_name \
    --image-scanning-configuration scanOnPush=true \
    --region us-west-1

docker buildx build --platform=linux/amd64 -t 948243776115.dkr.ecr.us-west-1.amazonaws.com/$repo_name .
docker push 948243776115.dkr.ecr.us-west-1.amazonaws.com/$repo_name


#### Need to update image to include the repo url: 948243776115.dkr.ecr.us-west-1.amazonaws.com/$repo_name
# Creates an AWS Load balancer, nodeport, and deployment 
kubectl apply -f aws.yaml


