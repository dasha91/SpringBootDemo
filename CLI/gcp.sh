##################################################  INSTALL PREREQUISITES ##################################################
# Set up a docker account 
gcloud components install docker-credential-gcr
gcloud components install kubectl
gcloud components install gke-gcloud-auth-plugin

##################################################  Set Parameters ##################################################
gcloud config set project angular-axe-306514
gcloud config set compute/zone us-west1

Create artifact repository
gcloud artifacts repositories create spring-boot-demo-repo --repository-format=docker --location=us-west1

docker buildx build --platform=linux/amd64  -t us-west1-docker.pkg.dev/angular-axe-306514/spring-boot-demo-repo/spring-boot-demo:v9 .

gcloud artifacts repositories add-iam-policy-binding spring-boot-demo-repo \
    --location=us-west1 \
    --member=serviceAccount:204515338375-compute@developer.gserviceaccount.com \
    --role="roles/artifactregistry.reader"

gcloud auth configure-docker us-west1-docker.pkg.dev

docker push us-west1-docker.pkg.dev/angular-axe-306514/spring-boot-demo-repo/spring-boot-demo:v9

kubectl create deployment spring-boot-deployment9 --image=us-west1-docker.pkg.dev/angular-axe-306514/spring-boot-demo-repo/spring-boot-demo:v9

docker tag spring-boot-demo.jar:latest us-west1-docker.pkg.dev/angular-axe-306514/spring-boot-demo-repo/spring-boot-demo:v9

gcloud container clusters create spring-boot-cluster

gcloud container clusters get-credentials spring-boot-cluster

