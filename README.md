# SpringBootDemo
Spring Boot application that we will deploy to Kubernetes clusters in all 3 clouds


# Deploying to VM

## Azure 
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


ssh ${ADMIN_USERNAME}@${VM_IP_ADDRESS}

# adding a mix of this file on how to install tomcat https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-9-on-debian-10 

# Update and install Java/Maven
sudo apt update
sudo apt install default-jdk
sudo apt install maven

# Now it's time to clone the project into the vm itself
cd /opt
sudo git clone https://github.com/dasha91/SpringBootDemo
cd SpringBootDemo
# Run the following to give app access to create files/directories: 
sudo chmod -R 777 /opt/SpringBootDemo/

# Run and deploy the app
mvn clean install
mvn spring-boot:run  

# Go TO http://[$VM_IP_ADDRESS]:8080 to confirm that it's working :D :D :D 

