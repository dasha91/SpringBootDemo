
##################################################  Set Parameters ##################################################
export location="EastUS"
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

##################################################  Create Postgres (4m 29.6861s) #################################################
# 9.1576s
az group create --name $resourceGroup --location "$location" | gnomon

# 3.6951s
export password=$(az keyvault secret show --name "postgres-password" --vault-name $keyvaultName --query "value" -o tsv) | gnomon

# 129.8412s
az postgres server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $password --sku-name $sku --public disabled | gnomon

#22.2044s
az postgres db create -g $resourceGroup -s $server -n $databaseName | gnomon

#1.5286s
export postgresId=$(az resource show -g $resourceGroup -n $server --resource-type "Microsoft.DBforPostgreSQL/servers" --query "id" -o tsv) | gnomon

# Useful docs: https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-configure-privatelink-portal
# Following: https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-configure-privatelink-cli (TODO documentation is buggy. commands have weird includes and the postgres create isn't private which should be given the doc)
# What, where is mydemopostgressserver coming from at the end????
# 34.5843s
az network private-endpoint create --name myPrivateEndpoint --resource-group $resourceGroup --vnet-name $vnetName --subnet $subnetName --private-connection-resource-id $postgresId --group-id postgresqlServer --connection-name cli-postgres-connection | gnomon 

# 34.8367s
az network private-dns zone create --resource-group $resourceGroup --name  "privatelink.postgres.database.azure.com" | gnomon

# 34.5264s
az network private-dns link vnet create --resource-group $resourceGroup --zone-name  "privatelink.postgres.database.azure.com" --name cli-dns-link --virtual-network $vnetName --registration-enabled false | gnomon

# 1.9377s
networkInterfaceId=$(az network private-endpoint show --name myPrivateEndpoint --resource-group $resourceGroup --query 'networkInterfaces[0].id' -o tsv) | gnomon

# 1.0283s
privateIPAddress=$(az resource show --ids $networkInterfaceId --api-version 2019-04-01 --query 'properties.ipConfigurations[0].properties.privateIPAddress' -o tsv) | gnomon
# 2.0335s
az network private-dns record-set a create --name myserver --zone-name privatelink.postgres.database.azure.com --resource-group $resourceGroup  | gnomon

# TODO: set whatever arecord into the azure.yaml file as well. example: myserver.privatelink.postgres.database.azure.com
# 2.4699s
az network private-dns record-set a add-record --record-set-name myserver --zone-name privatelink.postgres.database.azure.com --resource-group $resourceGroup -a $privateIPAddress | gnomon

##################################################  Create Container Registry (2m 43.9371s) ##################################################
# 11.5072s
az acr create -n $containerRegistry -g $resourceGroup --sku basic | gnomon 
# 5.8333s
az acr login --name $containerRegistry | gnomon 

# 2.1747s
docker buildx build --platform=linux/amd64 -t $containerRegistry.azurecr.io/spring-boot-demo:v1 . | gnomon 

# Need to also update the deployment image in the azure.yaml file with whatever version is below
# 144.4219s
docker push $containerRegistry.azurecr.io/spring-boot-demo:v | gnomon 

##################################################  Create AKS (4m 15.1777s)  ################################################## 


# 14.2188s
az network vnet create --name $vnetName --resource-group $resourceGroup --subnet-name $subnetName | gnomon

#2.4336s
az network vnet subnet update --name $subnetName --resource-group $resourceGroup --vnet-name $vnetName --disable-private-endpoint-network-policies true | gnomon

# 1.8258s
subnetId=$(az network vnet subnet show --name $subnetName --resource-group $resourceGroup --vnet-name $vnetName --query "id" -o tsv) | gnomon 

# 226.0126s
az aks create -n $clusterName -g  $resourceGroup --generate-ssh-keys --attach-acr $containerRegistry --vnet-subnet-id $subnetId --service-cidr 10.1.0.0/16 --network-plugin azure  --dns-service-ip 10.1.0.10 | gnomon  

# 1.4867s
az aks get-credentials -g $resourceGroup -n $clusterName | gnomon 

# 1.0426s (Counts as postgres)
kubectl create secret generic kubernetes-db-secret \
  --from-literal=username=postgres \
  --from-literal=password=$password \
  --from-literal=database=$databaseName | gnomon 

##################################################  Installing Ingress controller (24.3502s) ##################################################
# 0.4219s
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx | gnomon  

# 23.9283s
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $ingressNamespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz | gnomon

##################################################  Creating deployment with ingress (6.4983) ##################################################
# 1.4983s + 5s for ingress to come up
kubectl apply -f CLI/azure.yaml | gnomon

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
