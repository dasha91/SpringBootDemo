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
docker buildx build --platform=linux/amd64 -t us-west1-docker.pkg.dev/cci-sandbox-danial/spring-boot-demo-repo/spring-boot-demo:v3 .

################################################## push docker image to artifact registry ##################################################
gcloud auth configure-docker us-west1-docker.pkg.dev
docker push us-west1-docker.pkg.dev/cci-sandbox-danial/spring-boot-demo-repo/spring-boot-demo:v3

################################################## Create cluster  ##################################################
gcloud container clusters create spring-boot-cluster --workload-pool=cci-sandbox-danial.svc.id.goog
gcloud container clusters get-credentials spring-boot-cluster

################################################## Create deployment to  ##################################################
kubectl create deployment spring-boot-deployment2 --image=us-west1-docker.pkg.dev/cci-sandbox-danial/spring-boot-demo-repo/spring-boot-demo:v2
kubectl apply -f Load-balancer-gcp.yaml #Make sure to update internal-lb app to the deployment name: spring-boot-deployment1

################### Create Postgres db ######################
gcloud sql instances create spring-boot-postgres-instance --database-version=POSTGRES_14 --cpu=2 --memory=7680MB --region=us-west1
gcloud sql users set-password postgres --instance=spring-boot-postgres-instance --password=Sup3rS3cret!
gcloud sql databases create demo --instance=spring-boot-postgres-instance

kubectl create secret generic kubernetes-db-secret \
  --from-literal=username=postgres \
  --from-literal=password=Sup3rS3cret! \
  --from-literal=database=demo

# activate workload identity on cluster
gcloud container clusters update spring-boot-cluster \
    --workload-pool=cci-sandbox-danial.svc.id.goog

kubectl apply -f ./CLI/service-account.yaml


############## Create Service account for cloud sql auth proxy 
# Following this doc: https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine
# and https://cloud.google.com/sql/docs/mysql/connect-auth-proxy#create-service-account

gcloud iam service-accounts create postgres-springboot-demo-sa \
    --description="service account to give springboot-demo app access to cloud sql account" \
    --display-name="springboot-postgress-sa"

gcloud projects add-iam-policy-binding cci-sandbox-danial \
    --member="serviceAccount:postgres-springboot-demo-sa@cci-sandbox-danial.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding cci-sandbox-danial \
    --member="serviceAccount:postgres-springboot-demo-sa@cci-sandbox-danial.iam.gserviceaccount.com" \
    --role="roles/cloudsql.client" 

gcloud iam service-accounts add-iam-policy-binding \
--role="roles/iam.workloadIdentityUser" \
--member="serviceAccount:cci-sandbox-danial.svc.id.goog[default/kubernetes-db-secret]" \
postgres-springboot-demo-sa@cci-sandbox-danial.iam.gserviceaccount.com

kubectl annotate serviceaccount \
kubernetes-db-secret \
iam.gke.io/gcp-service-account=postgres-springboot-demo-sa@cci-sandbox-danial.iam.gserviceaccount.com

kubectl annotate serviceaccount cloudsql-proxy default gke.io/gcp-service-account=cloudsql-proxy-dev@foobar.iam.gserviceaccount.com


kubectl apply -f ./CLI/proxy_with_workload_identity.yaml
