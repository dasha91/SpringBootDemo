# For actually documenting the time of runs use:
# terraform plan -out=plan_output.tfplan
# terraform apply "plan_output.tfplan" | gnomon --type=elapsed-total 
variable "virtual_network_address_prefix" {
  description = "VNET address prefix"
  default     = "192.168.0.0/16"
}

variable "aks_subnet_name" {
  description = "Subnet Name."
  default     = "kubesubnet"
}

variable "aks_subnet_address_prefix" {
  description = "Subnet address prefix."
  default     = "192.168.0.0/24"
}


data "azurerm_key_vault" "example" {
  name                = "AXA-Compete-Key-Vault"
  resource_group_name = "AXA-Root"
}

data "azurerm_key_vault_secret" "postgres-password" {
  name         = "postgres-password"
  key_vault_id = data.azurerm_key_vault.example.id
}


##################################################  Create Postgres (3m 0.75s) #################################################
#You ask to use modeule, but documentation leads me to use the stratight resources: https://learn.microsoft.com/en-us/azure/developer/terraform/deploy-postgresql-flexible-server-database?tabs=azure-cli
# Got the following error, but unclear on what feature I need to enable or what rule it's even creating: 
# │ Error: creating Virtual Network Rule (Subscription: "ad70ac39-7cb2-4ed2-8678-f192bc4272b6"
# │ Resource Group Name: "aks-postgres-terraform"
# │ Server Name: "aks-terraform-postgres"
# │ Virtual Network Rule Name: "postgresql-vnet-rule-kubesubnet-rule"): performing CreateOrUpdate: virtualnetworkrules.VirtualNetworkRulesClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error: Code="FeatureSwitchNotEnabled" Message="Requested feature is not enabled"
# │ 
# │   with module.postgresql.azurerm_postgresql_virtual_network_rule.vnet_rules[0],
# │   on .terraform/modules/postgresql/main.tf line 56, in resource "azurerm_postgresql_virtual_network_rule" "vnet_rules":
# │   56: resource "azurerm_postgresql_virtual_network_rule" "vnet_rules" {

module "postgresql" { # 2m 19
  source = "Azure/postgresql/azurerm"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  server_name                   = "aks-terraform-postgres"
  sku_name                      = "GP_Gen5_2"
  storage_mb                    = 5120
  auto_grow_enabled             = false
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  administrator_login           = "postgres"
  administrator_password        = data.azurerm_key_vault_secret.postgres-password.value
  server_version                = "11"
  ssl_enforcement_enabled       = true
  public_network_access_enabled = false
  db_names                      = ["demo"]
  db_charset                    = "UTF8" # Do we need these? Can these be defaults?
  db_collation                  = "English_United States.1252" # Do we need these? Can these be defaults?

  # vnet_rule_name_prefix = "postgresql-vnet-rule-"
  # vnet_rules = [
  #   { name = "kubesubnet-rule", subnet_id = azurerm_subnet.kubesubnet.id}
  # ]

  depends_on = [azurerm_resource_group.rg]
}

# resource "azurerm_postgresql_server" "postgres" { # 2m9s
#   location                         = azurerm_resource_group.rg.location
#   name                             = "aks-terraform-postgres"
#   resource_group_name              = azurerm_resource_group.rg.name
#   sku_name                         = "GP_Gen5_2"
#   ssl_enforcement_enabled          = true
#   ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
#   version                          = "11"
#   administrator_login              = "postgres"
#   administrator_login_password     = data.azurerm_key_vault_secret.postgres-password.value
#   public_network_access_enabled    = false
#   threat_detection_policy {
#     enabled = true
#   }
#   depends_on = [
#     azurerm_resource_group.rg,
#   ]
# }

# resource "azurerm_postgresql_database" "demoDB" { # 17s
#   charset             = "UTF8"
#   collation           = "English_United States.1252"
#   name                = "demo"
#   resource_group_name = azurerm_resource_group.rg.name
#   server_name         = azurerm_postgresql_server.postgres.name
# }

resource "azurerm_private_endpoint" "postgresEndpoint" { # 38s
  name                = "postgresEndpoint"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.kubesubnet.id

  private_service_connection {
    name                           = "terraform-postgres-connection"
    private_connection_resource_id = module.postgresql.server_id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "dns_zone" { # 34s
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" { # 34s 
  name                  = "terraform-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.aksVnet.id
}

resource "azurerm_private_dns_a_record" "example" { #2s
  name                = "myserver"
  resource_group_name = azurerm_resource_group.rg.name
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.postgresEndpoint.private_service_connection[0].private_ip_address]
}

resource "kubernetes_secret" "db-secret" { #1s
  metadata {
    name = "db-secret"
  }

  data = {
    username = "postgres"
    password = data.azurerm_key_vault_secret.postgres-password.value
    database = "demo"
  }
}
##################################################  Create AKS (4m 18.423s) ##################################################
resource "azurerm_resource_group" "rg" { # 1s
  location = "eastus"
  name     = "aks-postgres-terraform"
}

// az aks get-credentials -g aks-postgres-terraform -n aks-terraform-cluster
resource "azurerm_kubernetes_cluster" "aks" { # 3m43s
  dns_prefix          = "aks-terraform-postgres"
  location            = azurerm_resource_group.rg.location
  name                = "aks-terraform-cluster"
  resource_group_name = azurerm_resource_group.rg.name
  default_node_pool {
    name    = "default"
    node_count      = 2
    vm_size = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.kubesubnet.id
  }
  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

resource "azurerm_role_assignment" "acr_role_assignment" { #24s
  scope                = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerRegistry/registries/postgresacr"
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_virtual_network" "aksVnet" { #6s
  name                = "Terraform-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.virtual_network_address_prefix]
}

resource "azurerm_subnet" "kubesubnet" { #5s
    name           = var.aks_subnet_name
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.aksVnet.name
    address_prefixes                                 = [var.aks_subnet_address_prefix]
   private_link_service_network_policies_enabled = false
}  

##################################################  Creating deployment with ingress (48.5765s) ##################################################
resource "kubernetes_ingress_v1" "ingress" { #1s
  metadata {
    name = "ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }
  spec {
    ingress_class_name = "nginx"
    default_backend {
      service {
        name = kubernetes_service.nodeport.metadata.0.name
        port {
          number = 80
        }
      }
    }
  }
  depends_on = [ helm_release.ingress_nginx ]
}

resource "kubernetes_service" "nodeport" { #1s
  metadata {
    name = "node-port"
  }
  spec {
    selector = {
      App = kubernetes_deployment.demo_deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "demo_deployment" { #27s
  metadata {
    name = "deployment"
  }

  spec {
    selector {
      match_labels = {
        App = "spring-boot-demo"
      }
    }

    template {
      metadata {
        labels = {
          App = "spring-boot-demo"
        }
      }

      spec {
        container {
          image = "postgresacr.azurecr.io/spring-boot-demo:v4"
          name  = "spring-boot-demo"
        }
      }
    }
  }
  depends_on = [ azurerm_role_assignment.acr_role_assignment ]
}

resource "helm_release" "ingress_nginx" { #58s
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"

  set {
    name  = "controller.service.annotations.service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path"
    value = "healthz"
  }
}