resource "azurerm_resource_group" "rg" {
  name     = "Terraform-rg"
  location = "West US 2"
}

// Creates the AKS cluster in the virtual networks defined below and will additionally create the ingress appication gateway
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "Terraform-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "Terraform-k8s"

   default_node_pool {
     name            = "default"
     node_count      = 0
     vm_size         = "Standard_D2_v2"
     vnet_subnet_id = data.azurerm_subnet.kubesubnet.id
   }

  network_profile {
      network_plugin  = "azure"
      network_policy =  "azure"
  }

  identity {
    type = "SystemAssigned"
  }

  ingress_application_gateway {
    subnet_id = data.azurerm_subnet.appgwsubnet.id

  }
}

resource "kubernetes_ingress_v1" "app-gateway-ingress" {
  metadata {
    name = "app-gateway-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "azure/application-gateway"
      "kubernetes.io/tls-acme" = "true"
      "appgw.ingress.kubernetes.io/ssl-redirect" = "true"
      "cert-manager.io/cluster-issuer" = "letsencrypt"
    }
  }
  spec {
    tls {
      hosts = [data.local_file.public_ip_fqdn.content]
      secret_name = "azure-vote-secret"
    }
    rule {
      host = data.local_file.public_ip_fqdn.content
      http {
        path {
          path = "/"
          backend {
            service {
              name = "azure-vote-front"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    data.local_file.public_ip_fqdn, null_resource.set_and_get_public_ip_fqdn
  ]
}

