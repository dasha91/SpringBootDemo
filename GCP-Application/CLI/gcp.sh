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
### Assuming there is a password in secret manager with name below and value 'Sup3rS3cret!' 
export postgresPassword=postgres-password

gcloud config set project $project
##################################################  Create Cluster (6m 47.4783s) ##################################################
# 14.8343s
gcloud compute networks create $vpcName --subnet-mode=custom | gnomon

# Create a subnet in the VPC 13.9301s
gcloud compute networks subnets create $subnetName --network=$vpcName --range=192.168.0.0/20 --region=$region | gnomon

# Create the GKE cluster in the specified network and subnet 377.5258s
gcloud container clusters create $gkeName --zone=$zone --network=$vpcName --subnetwork=$subnetName --workload-pool=$project.svc.id.goog | gnomon

# Configure kubectl to use the new cluster 1.1881s
gcloud container clusters get-credentials $gkeName --zone=$zone | gnomon

##################################################  Create Postgres and connect privately (4m 52.1334s)##################################################
# Creating private access connection: https://cloud.google.com/sql/docs/postgres/configure-private-services-access
# 4.1585s
gcloud compute addresses create $addressRangeName \
  --global \
  --purpose=VPC_PEERING \
  --prefix-length=16 \
  --network=projects/$project/global/networks/$vpcName | gnomon

#40.4560s
gcloud services vpc-peerings connect \
  --service=servicenetworking.googleapis.com \
  --ranges=$addressRangeName  \
  --network=$vpcName  \
  --project=$project | gnomon

# https://cloud.google.com/sql/docs/postgres/configure-private-service-connect#create-cloud-sql-instance-psc-enabled
# 240.1133s
gcloud beta sql instances create $posgresInstanceName \
  --project=$project \
  --region=$region \
  --availability-type=regional \
  --no-assign-ip \
  --network=projects/$project/global/networks/$vpcName \
  --tier=db-g1-small \
  --database-version=POSTGRES_14 | gnomon

# 1.0544s Get the connection name and update the application.properties file
gcloud beta sql instances describe $posgresInstanceName \
  --project=$project | grep connectionName | gnomon

# 3.0415s
gcloud sql databases create $dbName --instance=$posgresInstanceName  | gnomon

# 1.0091s
Password=$(gcloud secrets versions access latest --secret=$postgresPassword)  | gnomon

# 2.3006s
gcloud sql users set-password postgres --instance=$posgresInstanceName --password=$Password  | gnomon

##################################################  Create Artifact registry (1m 48.1893s) ##################################################
# 2.3348s
gcloud artifacts repositories create $artifactRegistry --repository-format=docker --location=$region | gnomon

#If you're on a M1 mac: 3.1249s
docker buildx build --platform=linux/amd64 -t $region-docker.pkg.dev/$project/$artifactRegistry/spring-boot-demo:v3 . | gnomon

# 0.9475s
gcloud auth configure-docker $region-docker.pkg.dev | gnomon 

# 101.7821s
docker push $region-docker.pkg.dev/$project/$artifactRegistry/spring-boot-demo:v3 | gnomon

################################################## Configure Cloud SQL Auth Proxy (Counts in Postgres) (17.1875s) ##################################################
#1.5542s
gcloud iam service-accounts create postgres-springboot-demo-sa \
    --description="service account to give springboot-demo app access to cloud sql account" \
    --display-name="springboot-postgress-sa" | gnomon 

#1.6308s
gcloud projects add-iam-policy-binding $project \
    --member="serviceAccount:postgres-springboot-demo-sa@$project.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"  | gnomon 

#  1.7671s
kubectl create serviceaccount kubernetes-sa  | gnomon 
# 0.4821s
kubectl annotate serviceaccount \
kubernetes-sa \
iam.gke.io/gcp-service-account=postgres-springboot-demo-sa@$project.iam.gserviceaccount.com  | gnomon  

# 11.3766s
gcloud iam service-accounts add-iam-policy-binding \
--role="roles/iam.workloadIdentityUser" \
--member="serviceAccount:$project.svc.id.goog[default/kubernetes-sa]" \
postgres-springboot-demo-sa@$project.iam.gserviceaccount.com  | gnomon 

# 0.3767s
kubectl create secret generic kubernetes-db-secret \
  --from-literal=username=postgres \
  --from-literal=password=$Password \
  --from-literal=database=$dbName  | gnomon 

##################################################  Creating deployment with ingress ##################################################

# 4.5492s + 120s for ingress to come up
kubectl apply -f ./CLI/gcp.yaml | gnomon 
