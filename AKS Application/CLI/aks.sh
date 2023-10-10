
##################################################  Set Parameters ##################################################
export suffix=$(openssl rand -base64 4 | tr -dc 'a-z0-9')
export location="EastUS"
export resourceGroup="aks-postgres-demo"
export server="postgres-server-$suffix"
export sku="GP_Gen5_2"
export login="postgres"
export containerRegistry=aksacr$suffix
export clusterName=aks-postgres-cluster
export ingressNamespace=ingress-basic
export databaseName=demo
export vnetName=aks-postgres-vnet
export subnetName=aks-postgres-subnet

# Generate random password
export password=$(date | base64)

##################################################  Create Postgres #################################################

az group create --name $resourceGroup --location "$location" 

az postgres server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $password --sku-name $sku --public disabled 

az postgres db create -g $resourceGroup -s $server -n $databaseName 

export postgresId=$(az resource show -g $resourceGroup -n $server --resource-type "Microsoft.DBforPostgreSQL/servers" --query "id" -o tsv) 

az network vnet create --name $vnetName --resource-group $resourceGroup --subnet-name $subnetName 

az network vnet subnet update --name $subnetName --resource-group $resourceGroup --vnet-name $vnetName --disable-private-endpoint-network-policies true 

subnetId=$(az network vnet subnet show --name $subnetName --resource-group $resourceGroup --vnet-name $vnetName --query "id" -o tsv)  

az network private-endpoint create --name myPrivateEndpoint --resource-group $resourceGroup --vnet-name $vnetName --subnet $subnetName --private-connection-resource-id $postgresId --group-id postgresqlServer --connection-name cli-postgres-connection  

az network private-dns zone create --resource-group $resourceGroup --name  "privatelink.postgres.database.azure.com" 

az network private-dns link vnet create --resource-group $resourceGroup --zone-name  "privatelink.postgres.database.azure.com" --name cli-dns-link --virtual-network $vnetName --registration-enabled false 

networkInterfaceId=$(az network private-endpoint show --name myPrivateEndpoint --resource-group $resourceGroup --query 'networkInterfaces[0].id' -o tsv) 

privateIPAddress=$(az resource show --ids $networkInterfaceId --api-version 2019-04-01 --query 'properties.ipConfigurations[0].properties.privateIPAddress' -o tsv) 

az network private-dns record-set a create --name mypostgresserver --zone-name privatelink.postgres.database.azure.com --resource-group $resourceGroup  

az network private-dns record-set a add-record --record-set-name mypostgresserver --zone-name privatelink.postgres.database.azure.com --resource-group $resourceGroup -a $privateIPAddress 

export DNS=mypostgresserver.privatelink.postgres.database.azure.com

##################################################  Create Container Registry (2m 43.9371s) ##################################################
az acr create -n $containerRegistry -g $resourceGroup --sku basic  
az acr login --name $containerRegistry  

export IMAGE=$containerRegistry.azurecr.io/spring-boot-demo:v1

# Use "docker build -t $IMAGE ../." if on non M1 mac
docker buildx build --platform=linux/amd64 -t $IMAGE ../.  

docker push $IMAGE  

##################################################  Create AKS (4m 15.1777s)  ################################################## 

az aks create -n $clusterName -g  $resourceGroup --generate-ssh-keys --attach-acr $containerRegistry --vnet-subnet-id $subnetId --service-cidr 10.1.0.0/16 --network-plugin azure  --dns-service-ip 10.1.0.10   

az aks get-credentials -g $resourceGroup -n $clusterName  

##################################################  Installing Ingress controller (24.3502s) ##################################################
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx   

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $ingressNamespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz 

##################################################  Creating deployment with ingress (6.4983) ##################################################

export USER=$login@$server

sed -e "s|<IMAGE_NAME>|${IMAGE}|g" \
    -e "s|<DNS>|${DNS}|g" \
    -e "s|<DB_NAME>|${databaseName}|g" \
    -e "s|<USERNAME>|${USER}|g" \
    -e "s|<PASSWORD>|${password}|g" deployment-template.yaml > deployment.yaml

kubectl apply -f deployment.yaml 


echo "Retrieving AKS Ingress IP Address..."
while true; do
    aks_cluster_ip=$(kubectl get ingress ingress -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -n "$aks_cluster_ip" ]]; then
        echo "AKS Ingress IP Address is: $aks_cluster_ip"
        break
    else
        echo "Waiting for AKS Ingress IP Address to be assigned..."
        sleep 15s
    fi
done

echo "---------- AKS ----------"
echo "AKS Ingress IP Address: $aks_cluster_ip"
echo "To access the AKS cluster, use the following command:"
echo "az aks get-credentials -g $resourceGroup -n aks-terraform-cluster"
echo "the postgres username is $USER and the password is $password"
echo ""


