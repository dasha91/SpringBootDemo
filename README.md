# SpringBootDemo
Spring Boot application that we will deploy to Kubernetes clusters in all 3 clouds

# Building and deploying the docker image: 
mvn clean install
mvn spring-boot:run  

docker build -t spring-boot-demo.jar .
docker run -p 9091:8080 spring-boot-demo.jar

# Deploying to Kubernetes

## GKE 

Requirements: 
Set up a docker account 
gcloud components install docker-credential-gcr
gcloud components install kubectl
gcloud config set project angular-axe-306514

Create artifact repository
gcloud artifacts repositories create spring-boot-demo-repo --repository-format=docker --location=us-west1


docker buildx build --platform=linux/amd64  -t us-west1-docker.pkg.dev/angular-axe-306514/spring-boot-demo-repo/spring-boot-demo:v8 .

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




# Deploying to VM

## Azure 

### Create and connect to the VM 
Set up parameter variables: 

```export SUBSCRIPTION=ad70ac39-7cb2-4ed2-8678-f192bc4272b6 # customize this
export RESOURCE_GROUP=SpringBoot # customize this
export REGION=westus2 # customize this
export VM_NAME=springboot-vm
export VM_IMAGE=UbuntuLTS
export ADMIN_USERNAME=vm-admin-name # customize this
```

Log in and create VM: 

```az login 
az account set --subscription ${SUBSCRIPTION}
az group create --name ${RESOURCE_GROUP} --location ${REGION}
az vm create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${VM_NAME} \
  --image ${VM_IMAGE} \
  --admin-username ${ADMIN_USERNAME} \
  --generate-ssh-keys \
  --public-ip-sku Standard --size standard_d4s_v3
  ```

Store the VM IP address for later: 

```
VM_IP_ADDRESS=`az vm show -d -g ${RESOURCE_GROUP} -n ${VM_NAME} --query publicIps -o tsv` 
```

Run the following to open port 8080 on the vm since SpringBoot uses it

`az vm open-port --port 8080 --resource-group ${RESOURCE_GROUP} --name ${VM_NAME} --priority 1100`

Connect to the VM: 

`ssh ${ADMIN_USERNAME}@${VM_IP_ADDRESS}`

### Deploy the application
Install Java and maven needed for application
```sudo apt update
sudo apt install default-jdk
sudo apt install maven
```
Now it's time to clone the project into the vm and give it proper permissions: 
```
cd /opt
sudo git clone https://github.com/dasha91/SpringBootDemo
cd SpringBootDemo
sudo chmod -R 777 /opt/SpringBootDemo/
```

Run and deploy the app
```mvn clean install
mvn spring-boot:run  
```

Finally go to http://[$VM_IP_ADDRESS]:8080 to confirm that it's working :D :D :D 


## GCP 

### Create and connect to the VM 
Set up parameter variables: 

```
export PROJECT=danial-sandbox 
export COMPUTE_ZONE=us-west1-b
export IMAGE_PROJECT=ubuntu-os-pro-cloud # customize this
export VM_NAME=springboot-vm3
export IMAGE_FAMILY=ubuntu-pro-2004-lts
```

Log in and create VM: 

```
gcloud config set project ${PROJECT}
gcloud config set compute/zone ${COMPUTE_ZONE}
gcloud compute instances create ${VM_NAME} \
    --image-family=${IMAGE_FAMILY} \
    --image-project=${IMAGE_PROJECT}
  ```

Store the external VM IP address for later: 35.247.53.26

Run the following to open port 8080 on the vm since SpringBoot uses it

```
gcloud compute firewall-rules create allow-ssh \
    --action=ALLOW \
    --direction=INGRESS \
    --priority=1000 \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create allow8080 \
    --action=ALLOW \
    --direction=INGRESS \
    --priority=1000 \
    --rules=tcp:8080 \
    --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create allow-outbound \
    --action=ALLOW \
    --direction=EGRESS \
    --priority=1000 \
    --rules=all \
    --source-ranges=0.0.0.0/0
```
Connect to the VM: 

either through this command: 

`gcloud compute ssh --project=${PROJECT} --zone=${COMPUTE_ZONE} ${VM_NAME}`

or through the portal at compute engine -> VM instances -> Connect SSH


