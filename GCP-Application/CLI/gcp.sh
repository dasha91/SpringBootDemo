##################################################  Set Parameters ##################################################
export region=us-west1
export zone="${region}-a"
export project=cci-sandbox-danial
export posgresInstanceName=spring-boot-postgres
export dbName=demo
export artifactRegistry=spring-boot-demo-repo
export gkeName=spring-boot-cluster
export vpcName=public-gke-vpc
export subnetName=public-gke-subnet
export addressRangeName=google-managed-services-$vpcName
gcloud config set project $project

################# Adding password secret to secret manager. Doesn't count towards compete 
gcloud services enable container.googleapis.com secretmanager.googleapis.com

echo 'Sup3rS3cret!' | gcloud secrets create postgres-password \
    --replication-policy="automatic" \
    --data-file=-

##################################################  Create Cluster ##################################################
gcloud compute networks create $vpcName --subnet-mode=custom

# Create a subnet in the VPC
gcloud compute networks subnets create $subnetName --network=$vpcName --range=192.168.0.0/20 --region=$region

# Create the GKE cluster in the specified network and subnet
gcloud container clusters create $gkeName --zone=$zone --network=$vpcName --subnetwork=$subnetName --workload-pool=$project.svc.id.goog

# Configure kubectl to use the new cluster
gcloud container clusters get-credentials $gkeName --zone=$zone

##################################################  Create Postgres and connect privately ##################################################
# Creating private access connection: https://cloud.google.com/sql/docs/postgres/configure-private-services-access
gcloud compute addresses create $addressRangeName \
  --global \
  --purpose=VPC_PEERING \
  --prefix-length=16 \
  --network=projects/$project/global/networks/$vpcName

gcloud services vpc-peerings connect \
  --service=servicenetworking.googleapis.com \
  --ranges=$addressRangeName  \
  --network=$vpcName  \
  --project=$project

# https://cloud.google.com/sql/docs/postgres/configure-private-service-connect#create-cloud-sql-instance-psc-enabled
gcloud beta sql instances create $posgresInstanceName \
  --project=$project \
  --region=$region \
  --availability-type=regional \
  --no-assign-ip \
  --network=projects/$project/global/networks/$vpcName \
  --tier=db-g1-small \
  --database-version=POSTGRES_14

gcloud sql databases create $dbName --instance=$posgresInstanceName

Password=$(gcloud secrets versions access latest --secret="postgres-password")

gcloud sql users set-password postgres --instance=$posgresInstanceName --password=$Password

##################################################  Create Artifact registry ##################################################

gcloud artifacts repositories create $artifactRegistry --repository-format=docker --location=$region # 5.7478s

#If you're on a M1 mac: 
docker buildx build --platform=linux/amd64 -t $region-docker.pkg.dev/$project/$artifactRegistry/spring-boot-demo:v1 . # 4.718s

gcloud auth configure-docker $region-docker.pkg.dev # 1.0493s
docker push $region-docker.pkg.dev/$project/$artifactRegistry/spring-boot-demo:v1

################################################## Configure Cloud SQL Auth Proxy (Counts in Postgres) ##################################################
gcloud iam service-accounts create postgres-springboot-demo-sa \
    --description="service account to give springboot-demo app access to cloud sql account" \
    --display-name="springboot-postgress-sa" #1.4762s

gcloud projects add-iam-policy-binding $project \
    --member="serviceAccount:postgres-springboot-demo-sa@$project.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin" #1.6448s

kubectl create serviceaccount kubernetes-sa # 1.3523s

kubectl annotate serviceaccount \
kubernetes-sa \
iam.gke.io/gcp-service-account=postgres-springboot-demo-sa@$project.iam.gserviceaccount.com # 0.5387s

gcloud iam service-accounts add-iam-policy-binding \
--role="roles/iam.workloadIdentityUser" \
--member="serviceAccount:$project.svc.id.goog[default/kubernetes-sa]" \
postgres-springboot-demo-sa@$project.iam.gserviceaccount.com # 1.4515s

kubectl create secret generic kubernetes-db-secret \
  --from-literal=username=postgres \
  --from-literal=password=$Password \
  --from-literal=database=$dbName

##################################################  Creating deployment with ingress ##################################################

kubectl apply -f ./CLI/gcp.yaml

# Once the ingress controller is created, run kubectl get ingress to get the ingress IP and run the following to enable internet access to the ingress controller: 
gcloud compute firewall-rules create allow-internet-ingress \
    --network=$vpcName \
    --direction=INGRESS \
    --source-ranges=34.36.5.78 \
    --action=ALLOW \
    --rules=all
