##################################################  Create Postgres  #################################################
# terraform import google_container_cluster.spring_boot_cluster cci-sandbox-danial/us-west1-b/spring-boot-cluster
resource "google_sql_database_instance" "postgres_instance" { #7m 48s
  database_version = "POSTGRES_14"
  name             = "terraform-postgres-instance"
  project = var.project_id
  region = var.region

  settings {
    tier         = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.custom_vpc.id
    }
    availability_type = "REGIONAL" 
  }
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_compute_global_address" "private_ip_address" {
  project = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom_vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.custom_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database" "demo-db" { #5s
  name     = "demo"
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "users" { #8s
  name     = "postgres"
  instance = google_sql_database_instance.postgres_instance.name
  password = data.google_secret_manager_secret_version.db_password.secret_data
}

data "google_secret_manager_secret_version" "db_password" {
  secret = "postgres-password"
}

##################################################  Creating Cloud SQL Proxy (Counts as Postgres)##################################################
resource "google_service_account" "postgres_springboot_demo_sa" { #2s
  account_id   = "postgres-terraform-sa"
  project      = var.project_id
}

resource "kubernetes_service_account" "kubernetes_sa" {
  metadata {
    name = "kubernetes-sa"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.postgres_springboot_demo_sa.email
    }
  }
  secret {
    name = "${kubernetes_secret.db-secret.metadata[0].name}"
  }
}

resource "kubernetes_secret" "db-secret" { #1s
  metadata {
    name = "db-secret"
  }

  data = {
    username = "postgres"
    password = data.google_secret_manager_secret_version.db_password.secret_data
    database = "demo"
  }
}

resource "google_project_iam_binding" "sql-admin-binding" { #8s
  project = var.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${google_service_account.postgres_springboot_demo_sa.email}",
  ]
}
resource "google_service_account_iam_binding" "admin-account-iam" { # 4s
  service_account_id = google_service_account.postgres_springboot_demo_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[default/${kubernetes_service_account.kubernetes_sa.metadata[0].name}]",
  ]
}

##################################################  Create GKE  ##################################################
# To Get cluster credentials: gcloud container clusters get-credentials cci-sandbox-danial-terraform-gke --zone=us-west1

resource "google_container_cluster" "gke" { #5m 46s
  project = var.project_id
  name    = "${var.project_id}-terraform-gke"
  location = var.region
  network = google_compute_network.custom_vpc.self_link
  subnetwork = google_compute_subnetwork.custom_subnet.self_link
  initial_node_count       = 1
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

output gke-name {
  value = google_container_cluster.gke.name
}

resource "google_compute_network" "custom_vpc" {
  name                    = "terraform-vpc"
  auto_create_subnetworks = false 
}

resource "google_compute_firewall" "allow_internet_ingress" {
  name    = "allow-terraform-ingress"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80","5432"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
}


# Create a subnet in the VPC
resource "google_compute_subnetwork" "custom_subnet" {
  name          = "terraform-subnet"
  ip_cidr_range = "192.168.0.0/20"
  region        = var.region
  network       = google_compute_network.custom_vpc.self_link
}

##################################################  Creating deployment with ingress ##################################################
// Ingress controller that passes traffic to the internal load balancer that sends traffic to the application itself.
resource "kubernetes_ingress_v1" "ingress" { #1s
  metadata {
    name = "managed-cert-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                 = "gce"
    }
  }
  spec {
    default_backend {
      service {
        name = kubernetes_service.lb.metadata[0].name
        port {
          number = 80
        }
      }
    }
  }
}

resource "kubernetes_service" "lb" { #1m 26s
  metadata {
    name = "lb"
     annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
     }
  }
  spec {
    selector = {
      App = kubernetes_deployment.spring-boot-demo.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

// This is the vote application that we are deploying. It's the same as the applications above and is based off 
// the Azure tutorial found here: https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app
resource "kubernetes_deployment" "spring-boot-demo" { #26s
  metadata {
    name = "spring-boot-demo"
    labels = {
      App = "spring-boot-demo"
    }
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
        service_account_name = kubernetes_service_account.kubernetes_sa.metadata.0.name
        container {
          image = "us-west1-docker.pkg.dev/cci-sandbox-danial/spring-boot-demo-repo/spring-boot-demo:v1"
          name  = "spring-boot-demo"
          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db-secret.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "DB_PASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db-secret.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db-secret.metadata[0].name
                key  = "database"
              }
            }
          }  
        }
        container {
          name  = "cloud-sql-proxy"
          image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.1.0"

          args = [
            "--structured-logs",
            "--port=5432",
            google_sql_database_instance.postgres_instance.connection_name
          ]

          security_context {
            run_as_non_root = true
          }

          resources {
            requests = {
              memory = "512Mi"
              cpu    = "0.25"
            }
          }
        }
      }
    }
  }
}





