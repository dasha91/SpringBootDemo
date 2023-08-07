##################################################  Set Parameters ##################################################
export region=us-west1
export project=cci-sandbox-danial
export posgresInstanceName=spring-boot-postgres
export dbName=demo
export artifactRegistry=spring-boot-demo-repo
export gkeName=spring-boot-cluster
gcloud config set project $project

##################################################  Create Artifact registry ##################################################
gcloud artifacts repositories create $artifactRegistry --repository-format=docker --location=$region # 5.7478s

#If you're on a M1 mac: 
docker buildx build --platform=linux/amd64 -t $region-docker.pkg.dev/$project/$artifactRegistry/spring-boot-demo:v1 . # 4.718s

gcloud auth configure-docker $region-docker.pkg.dev # 1.0493s
docker push $region-docker.pkg.dev/$project/$artifactRegistry/spring-boot-demo:v1 # 102.0280s

################################################## Create cluster  ##################################################
gcloud container clusters create $gkeName --workload-pool=$project.svc.id.goog #357.7312s
gcloud container clusters get-credentials $gkeName #4.0396s

##################################################  Create Postgres  ##################################################
gcloud sql instances create $posgresInstanceName --database-version=POSTGRES_14 --cpu=2 --memory=7680MB --region=$region #162.5642s
gcloud sql users set-password postgres --instance=$posgresInstanceName --password=Sup3rS3cret! #2.6922s
gcloud sql databases create $dbName --instance=$posgresInstanceName #2.3

################################################## Configure Cloud SQL Auth Proxy (Counts in Postgres) ##################################################
# Create Service account for cloud sql auth proxy 
# Following this doc: https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine
# and https://cloud.google.com/sql/docs/mysql/connect-auth-proxy#create-service-account
gcloud iam service-accounts create postgres-springboot-demo-sa \
    --description="service account to give springboot-demo app access to cloud sql account" \
    --display-name="springboot-postgress-sa" #1.4762s

gcloud projects add-iam-policy-binding $project \
    --member="serviceAccount:postgres-springboot-demo-sa@$project.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin" #1.6448s
V
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
  --from-literal=password=Sup3rS3cret! \
  --from-literal=database=$dbName #0.5499s

##################################################  Creating deployment with ingress ##################################################
kubectl apply -f ./CLI/gcp.yaml #2.4470s + 3m 42s to work end to end 
