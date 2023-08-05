

# Variable block
export location="East US"
export resourceGroup="aks-postgres-compete"
export server="aks-cli-postgres"
export sku="GP_Gen5_2"
export login="postgres"
export password=Sup3rS3cret!
export containerRegistry=postgresacr
export clusterName=aks-cli-cluster
export ingressNamespace=ingress-basic

az group create --name $resourceGroup --location "$location"

az postgres server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $password --sku-name $sku
az postgres db create -g $resourceGroup -s $server -n demo

az postgres server show --resource-group $resourceGroup --name $server

az extension add --name serviceconnector-passwordless --upgrade

az connection create postgres \
       --resource-group $resourceGroup \
       --connection postgres_conn \
       --target-resource-group $resourceGroup \
       --server aks-cli-postgres \
       --database demo \
       --user-account \
       --query authInfo.userName \
       --output tsv

# Tried to follow this: https://learn.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-data-jdbc-with-azure-postgresql?tabs=passwordless%2Cservice-connector&pivots=postgresql-passwordless-single-server 
# and the command ran, but couldn't get the passwordless connection to work .... not sure if I'm missing something or not :/ 
# When I tried logging in using the command username:aad_postgres_conn I got this error: The server requested password-based authentication, but no password was provided. 
az acr create -n $containerRegistry -g $resourceGroup --sku basic

az aks create -n $clusterName -g  $resourceGroup --generate-ssh-keys --attach-acr $containerRegistry

az aks get-credentials -g $resourceGroup -n $clusterName

az acr login --name $containerRegistry

az acr list --resource-group $resourceGroup --query "[].{acrLoginServer:loginServer}" --output table


docker buildx build --platform=linux/amd64 -t $containerRegistry.azurecr.io/spring-boot-demo:v1 .

docker push $containerRegistry.azurecr.io/spring-boot-demo:v1


helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $ingressNamespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

kubectl apply -f CLI/azure.yaml

##################################################  Helpful Docs ##################################################
# CNI enablement: https://learn.microsoft.com/en-us/azure/aks/configure-kubenet
# APP GW enablement: https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing
# Tutorial with simple vote app: https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli
# Helm docs to install cert manager: https://cert-manager.io/docs/installation/helm/
# Get TLS Working (partly helpfl): https://learn.microsoft.com/en-us/azure/aks/ingress-tls?tabs=azure-cli

##################################################  INSTALL PREREQUISITES ##################################################
# Install Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
# Install Azure 
# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
az aks install-cli # Install kubectl

##################################################  Set Parameters ##################################################
CLUSTER_NAME=aks-cli-cluster
RG=aks-cli-rg
LOCATION=westus2
VNET_NAME=aks-cli-vnet
DNSNAME=aks-cli-demo-25549

##################################################  Create Cluster ##################################################
az group create -n ${RG} -l ${LOCATION}
# Create a vnet with 2 subnets (1 for cluster and 1 for application gateway cluster). This is also needed to enable CNI
az network vnet create \
    --resource-group ${RG} \
    --name ${VNET_NAME} \
    --address-prefixes 192.168.0.0/16 \
    --subnet-name myAKSSubnet \
    --subnet-prefix 192.168.1.0/24

az network vnet subnet create \
    --resource-group ${RG} \
    --vnet-name ${VNET_NAME} \
    --name appgw-subnet \
    --address-prefixes 192.168.2.0/24

# Create azure cluster
az aks create -g ${RG} -n ${CLUSTER_NAME} --enable-managed-identity --node-count 2 --enable-addons ingress-appgw  \
  --network-plugin azure \
  --generate-ssh-keys \
  --network-policy azure
  --vnet-subnet-id /subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/${RG}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}/subnets/myAKSSubnet \
 --appgw-subnet-id /subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/${RG}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}/subnets/appgw-subnet

az aks get-credentials -n ${CLUSTER_NAME} -g ${RG}


##################################################  Deploy app ##################################################
kubectl apply -f azure-vote.yaml

##################################################  Enable HTTPS ##################################################
# Install cert manager 
kubectl create namespace cert-manager 

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
# Update your local Helm chart repository cache
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.crds.yaml
# Label the cert-manager namespace to disable resource validation
kubectl label namespace cert-manager cert-manager.io/disable-validation=true
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.10.0 

kubectl apply -f Azure-https.yaml

##################################################  Configure Public IP to FQDN ##################################################
# Get the resource id of the Application gateway to use to get the public IP ID in order to update the DNS name there
AppGWId=$(az aks show -g ${RG} -n ${CLUSTER_NAME} --query "addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId"  --output tsv)
# Get the resource-id of the public IP
PUBLICIPID=$(az network application-gateway show --ids ${AppGWId} --query "frontendIpConfigurations[0].publicIpAddress.id" --output tsv)
# Update public IP address with DNS name
az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME

################################################## Confirm SSL Enabled  ##################################################

# Confirm certificate is deployed
kubectl get certificate

##################### DELETE ##################

az group delete --name ${RG}