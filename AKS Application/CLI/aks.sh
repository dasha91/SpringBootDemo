
##################################################  Set Parameters ##################################################
export location="East US"
export resourceGroup="aks-postgres-compete"
export server="aks-cli-postgres"
export sku="GP_Gen5_2"
export login="postgres"
export password=Sup3rS3cret!
export containerRegistry=postgresacr
export clusterName=aks-cli-cluster
export ingressNamespace=ingress-basic
export databaseName=demo

##################################################  Create Postgres  ##################################################
az group create --name $resourceGroup --location "$location" #8.9s

az postgres server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $password --sku-name $sku #130s
az postgres db create -g $resourceGroup -s $server -n $databaseName #17.5s

# TODO: Need to take the qualified domain name and update the spring.datasource.url in the application.properties file 
az postgres server show --resource-group $resourceGroup --name $server --query "fullyQualifiedDomainName"  --output tsv #1.8s

az extension add --name serviceconnector-passwordless --upgrade #1.7s

# Tried to follow this: https://learn.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-data-jdbc-with-azure-postgresql?tabs=passwordless%2Cservice-connector&pivots=postgresql-passwordless-single-server 
# and the command ran, but couldn't get the passwordless connection to work .... not sure if I'm missing something or not :/ 
# When I tried logging in using the command username:aad_postgres_conn I got this error: The server requested password-based authentication, but no password was provided. 
az connection create postgres \ 
       --resource-group $resourceGroup \
       --connection postgres_conn \
       --target-resource-group $resourceGroup \
       --server $server \
       --database $databaseName \
       --user-account \
       --query authInfo.userName \
       --output tsv #76s

az postgres server firewall-rule create \
  --name AllowIPs \
  --resource-group $resourceGroup \
  --server $server \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255 #23s

##################################################  Create Container Registry  ##################################################
az acr create -n $containerRegistry -g $resourceGroup --sku basic #21.47s

az acr login --name $containerRegistry # 8.5s

docker buildx build --platform=linux/amd64 -t $containerRegistry.azurecr.io/spring-boot-demo:v1 . #4.17s

# Need to also update the deployment image in the azure.yaml file 
docker push $containerRegistry.azurecr.io/spring-boot-demo:v1 #125s

##################################################  Create AKS  ##################################################
az aks create -n $clusterName -g  $resourceGroup --generate-ssh-keys --attach-acr $containerRegistry #262s
az aks get-credentials -g $resourceGroup -n $clusterName #1s

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
