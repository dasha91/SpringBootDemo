##################################################  INSTALL PREREQUISITES ##################################################
# Set up a docker account 
gcloud components install docker-credential-gcr
gcloud components install kubectl
gcloud components install gke-gcloud-auth-plugin
gcloud services enable sqladmin.googleapis.com
# Enable the following APIs: Artifact Registry, Kubernetes Engine API

##################################################  Set Parameters ##################################################
gcloud config set project cci-sandbox-danial

##################################################  Create Artifact registry ##################################################
gcloud artifacts repositories create spring-boot-demo-repo --repository-format=docker --location=us-west1

################################################## Build docker image ##################################################

#If you're on a M1 mac: 
docker buildx build --platform=linux/amd64 -t us-west1-docker.pkg.dev/cci-sandbox-danial/spring-boot-demo-repo/spring-boot-demo:v1 .

################################################## push docker image to artifact registry ##################################################
gcloud auth configure-docker us-west1-docker.pkg.dev
docker push us-west1-docker.pkg.dev/cci-sandbox-danial/spring-boot-demo-repo/spring-boot-demo:v1

################################################## Create cluster  ##################################################
gcloud container clusters create spring-boot-cluster
gcloud container clusters get-credentials spring-boot-cluster

################################################## Create deployment to  ##################################################
kubectl create deployment spring-boot-deployment1 --image=us-west1-docker.pkg.dev/cci-sandbox-danial/spring-boot-demo-repo/spring-boot-demo:v1
kubectl apply Load-balancer-gcp.yaml #Make sure to update internal-lb app to the deployment name: spring-boot-deployment1

################### Create Postgres db ######################
gcloud sql instances create spring-boot-postgres-instance --database-version=POSTGRES_14 --cpu=2 --memory=7680MB --region=us-west1
gcloud sql users set-password postgres --instance=spring-boot-postgres-instance --password=Sup3rS3cret!
gcloud sql databases create demo --instance=spring-boot-postgres-instance
