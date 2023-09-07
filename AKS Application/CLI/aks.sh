
##################################################  Set Parameters ##################################################
export location="East US"
export resourceGroup="aks-postgres-compete"
export server="aks-cli-postgres"
export sku="GP_Gen5_2"
export login="postgres"
export containerRegistry=postgresacr
export clusterName=aks-cli-cluster
export ingressNamespace=ingress-basic
export databaseName=demo
export vnetName=cli-vnet
export subnetName=cli-subnet
export keyvaultName=AXA-Compete-Key-Vault

##################################################  Create Postgres  ##################################################
#https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-configure-privatelink-portal
az group create --name $resourceGroup --location "$location" #8.9s

# Following: https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-configure-privatelink-cli (TODO documentation is buggy. commands have weird includes and the postgres create isn't private which should be given the doc)
# WTF, where is mydemopostgressserver coming from at the end????
az network vnet create --name $vnetName --resource-group $resourceGroup --subnet-name $subnetName

az network vnet subnet update --name $subnetName --resource-group $resourceGroup --vnet-name $vnetName --disable-private-endpoint-network-policies true

export password=$(az keyvault secret show --name "postgres-password" --vault-name $keyvaultName --query "value" -o tsv)
az postgres server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $password --sku-name $sku --public disabled #130s
az postgres db create -g $resourceGroup -s $server -n $databaseName #17.5s

export postgresId=$(az resource show -g $resourceGroup -n $server --resource-type "Microsoft.DBforPostgreSQL/servers" --query "id" -o tsv)
az network private-endpoint create --name myPrivateEndpoint --resource-group $resourceGroup --vnet-name $vnetName --subnet $subnetName --private-connection-resource-id $postgresId --group-id postgresqlServer --connection-name cli-postgres-connection  

az network private-dns zone create --resource-group $resourceGroup --name  "privatelink.postgres.database.azure.com" 

az network private-dns link vnet create --resource-group $resourceGroup --zone-name  "privatelink.postgres.database.azure.com" --name cli-dns-link --virtual-network $vnetName --registration-enabled false

networkInterfaceId=$(az network private-endpoint show --name myPrivateEndpoint --resource-group $resourceGroup --query 'networkInterfaces[0].id' -o tsv)

privateIPAddress=$(az resource show --ids $networkInterfaceId --api-version 2019-04-01 --query 'properties.ipConfigurations[0].properties.privateIPAddress' -o tsv) 

az network private-dns record-set a create --name myserver --zone-name privatelink.postgres.database.azure.com --resource-group $resourceGroup  
az network private-dns record-set a add-record --record-set-name myserver --zone-name privatelink.postgres.database.azure.com --resource-group $resourceGroup -a $privateIPAddress


##################################################  Create Container Registry  ##################################################
az acr create -n $containerRegistry -g $resourceGroup --sku basic #21.47s

az acr login --name $containerRegistry # 8.5s

docker buildx build --platform=linux/amd64 -t $containerRegistry.azurecr.io/spring-boot-demo:v5 . #4.17s

# Need to also update the deployment image in the azure.yaml file 
docker push $containerRegistry.azurecr.io/spring-boot-demo:v5 #125s

##################################################  Create AKS  ##################################################
subnetId=$(az network vnet subnet show --name $subnetName --resource-group $resourceGroup --vnet-name $vnetName --query "id" -o tsv)
az aks create -n $clusterName -g  $resourceGroup --generate-ssh-keys --attach-acr $containerRegistry --vnet-subnet-id $subnetId --service-cidr 10.1.0.0/16 --network-plugin azure  --dns-service-ip 10.1.0.10 #262s
az aks get-credentials -g $resourceGroup -n $clusterName #1s

kubectl create secret generic kubernetes-db-secret \
  --from-literal=username=postgres \
  --from-literal=password=$password \
  --from-literal=database=$databaseName
##################################################  Installing Ingress controller  ##################################################

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx #.663s

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $ingressNamespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz #25.1s


##################################################  Creating deployment with ingress ##################################################
kubectl apply -f CLI/azure.yaml #1.29s

#ran: aztfexport resource-group aks-postgres-compete and it gave me a TON of resources. need to clean up most of it 
# 9-176 were azurerm_postgressql_configurations which all seem useless .... maybe make a note to remove???



##### Uneeded in private link model, but still a bad experience: 

# Tried to follow this: https://learn.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-data-jdbc-with-azure-postgresql?tabs=passwordless%2Cservice-connector&pivots=postgresql-passwordless-single-server 
# and the command ran, but couldn't get the passwordless connection to work .... not sure if I'm missing something or not :/ 
# When I tried logging in using the command username:aad_postgres_conn I got this error: The server requested password-based authentication, but no password was provided. 
az connection create postgres --resource-group $resourceGroup \
       --connection postgres_conn \
       --target-resource-group $resourceGroup \
       --server $server \
       --database $databaseName \
       --user-account \
       --query authInfo.userName \
       --output tsv #76s
