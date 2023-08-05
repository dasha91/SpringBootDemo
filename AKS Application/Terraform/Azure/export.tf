resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = "aks-postgres-terraform"
}

// az aks get-credentials -g aks-postgres-terraform -n aks-terraform-cluster
resource "azurerm_kubernetes_cluster" "aks" {
  dns_prefix          = "aks-terraform-postgres"
  location            = azurerm_resource_group.rg.location
  name                = "aks-terraform-cluster"
  resource_group_name = azurerm_resource_group.rg.name
  default_node_pool {
    name    = "default"
    node_count      = 2
    vm_size = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

resource "azurerm_role_assignment" "acr_role_assignment" {
  scope                = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerRegistry/registries/postgresacr"
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_postgresql_server" "postgres" {
  location                         = azurerm_resource_group.rg.location
  name                             = "aks-terraform-postgres"
  resource_group_name              = azurerm_resource_group.rg.name
  sku_name                         = "GP_Gen5_2"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  version                          = "11"
  administrator_login              = "psqladmin"
  administrator_login_password     = "Sup3rS3cret!"
  public_network_access_enabled    = true
  threat_detection_policy {
    enabled = true
  }
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

resource "azurerm_postgresql_database" "demoDB" {
  charset             = "UTF8"
  collation           = "English_United States.1252"
  name                = "demo"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgres.name
}

resource "azurerm_postgresql_firewall_rule" "allowIP" {
  end_ip_address      = "255.255.255.255"
  name                = "enable-global-connection"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgres.name
  start_ip_address    = "0.0.0.0"
}


resource "kubernetes_ingress_v1" "ingress" {
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
}

resource "kubernetes_service" "nodeport" {
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

resource "kubernetes_deployment" "demo_deployment" {
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
          image = "postgresacr.azurecr.io/spring-boot-demo:v1"
          name  = "spring-boot-demo"
        }
      }
    }
  }
  depends_on = [ azurerm_role_assignment.acr_role_assignment ]
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"

  set {
    name  = "controller.service.annotations.service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path"
    value = "healthz"
  }
}