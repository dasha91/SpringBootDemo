##################################################  INSTALL PREREQUISITES ##################################################
# Set up a docker account 
brew install eksctl

# Install AWS: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
# Enable the following APIs: Artifact Registry, Kubernetes Engine API

################################# Create EKS cluster #####################################

# Following this guide to create VPC: https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html
aws cloudformation create-stack \
  --region us-west-1 \
  --stack-name eks-vpc-stack \
  --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml

    aws iam create-role \
    --role-name eksClusterRole \
    --assume-role-policy-document file://"aws-cluster-trust-policy.json"

SubnetIDs=$(aws ec2 describe-subnets --filters "Name=tag:aws:cloudformation:logical-id,Values=PrivateSubnet02,PrivateSubnet01" \
--query "Subnets[].SubnetId" --output text| tr -s '\t' ',' )

# Creating the cluster 
eksctl create cluster --name spring-boot-demo-cluster --region us-west-1 --version 1.27 --vpc-private-subnets $SubnetIDs --without-nodegroup


# Create the artifact registry and push build: https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html
# This youtube video was helpful too: https://www.youtube.com/watch?v=vWSRWpOPHws&t=354s
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 948243776115.dkr.ecr.us-west-1.amazonaws.com
aws ecr create-repository \
    --repository-name springboot-demo-repo \
    --image-scanning-configuration scanOnPush=true \
    --region us-west-1

docker buildx build --platform=linux/amd64 -t 948243776115.dkr.ecr.us-west-1.amazonaws.com/springboot-demo-repo .
docker push 948243776115.dkr.ecr.us-west-1.amazonaws.com/springboot-demo-repo


################### Create DB ####################
aws rds create-db-instance \
    --engine postgres \
    --db-instance-identifier demo-postgres-interface \
    --allocated-storage 100 \
    --db-instance-class db.t3.micro	 \
    --master-username postgres \
    --master-user-password Sup3rS3cret!

####### Get endpoint and update the application.properties file in code
aws rds describe-db-instances \
    --query 'DBInstances[*].[Endpoint.Address]' \
    --filters Name=db-instance-id,Values=demo-postgres-interface \
    --output text

####### update VPCSecurityGroupID to allow connection from anywhere ########
VpcSgID=$(aws rds describe-db-instances \
    --filters Name=db-instance-id,Values=demo-postgres-interface \
    --query 'DBInstances[*].[VpcSecurityGroups[0].VpcSecurityGroupId]' --output text)

# If you want to look at security group first, run: aws ec2 describe-security-groups --group-ids $VpcSgID
aws ec2 authorize-security-group-ingress --group-id $VpcSgID --protocol tcp --port 5432 --cidr 0.0.0.0/0

###### Deploy load balancer on cluster ########
# Following: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

export cluster_name=spring-boot-demo-cluster

#Creating an IAM OIDC provider
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve 


# Configuring the Amazon VPC CNI plugin for Kubernetes to use IAM
eksctl create iamserviceaccount \
    --name aws-node \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name AmazonEKSVPCCNIRole \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --override-existing-serviceaccounts \
    --approve

CNIRoleARN=$(aws iam get-role --role-name AmazonEKSVPCCNIRole --query 'Role.Arn' --output text)

aws eks create-addon --cluster-name $cluster_name --addon-name vpc-cni --addon-version v1.13.2-eksbuild.1 \
    --service-account-role-arn $CNIRoleARN

aws eks create-addon --cluster-name $cluster_name --addon-name coredns --addon-version v1.9.3-eksbuild.3


aws eks describe-addon --cluster-name $cluster_name --addon-name kube-proxy --query addon.addonVersion --output text

KubeProxy=$(kubectl describe daemonset kube-proxy -n kube-system | awk '/Image:/ {print $2}')  

kubectl set image daemonset.apps/kube-proxy -n kube-system kube-proxy=$KubeProxy

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json

LBControlerPolicyARN=$(aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json --query 'Policy.Arn' --output text)

eksctl create iamserviceaccount \
  --cluster=$cluster_name \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=$LBControlerPolicyARN \
  --approve

  helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$cluster_name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

  kubectl get deployment -n kube-system aws-load-balancer-controller

kubectl apply -f aws.yaml


eksctl create nodegroup \
  --cluster $cluster_name \
  --region us-west-1 \
  --name my-nodegroup2 \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 2 \
  --node-private-networking \
  --nodes-max 4 \
 --subnet-ids $SubnetIDs


SubnetIDs=$(aws ec2 describe-subnets --filters "Name=tag:aws:cloudformation:logical-id,Values=PublicSubnet01,PrivateSubnet01" \
--query "Subnets[].SubnetId" --output text| tr -s '\t' ',' )


aws cloudformation describe-stack-events --stack-name eksctl-spring-boot-demo-cluster-nodegroup-my-nodegroup