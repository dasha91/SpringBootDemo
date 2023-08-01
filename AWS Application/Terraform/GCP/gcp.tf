resource "google_container_cluster" "gke" {
  project = var.project_id
  name    = "${var.project_id}-terraform-gke"
  location = var.region
  initial_node_count       = 1
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}
# terraform import google_container_cluster.spring_boot_cluster cci-sandbox-danial/us-west1-b/spring-boot-cluster
resource "google_sql_database_instance" "postgres_instance" {
  database_version = "POSTGRES_14"
  name             = "terraform-postgres-instance"
  project = var.project_id
  region = var.region

  settings {
    tier         = "db-f1-micro"
  }
}

resource "google_sql_database" "demo-db" {
  name     = "demo"
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "users" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres_instance.name
  password = "Sup3rS3cret!"
}


resource "google_service_account" "postgres_springboot_demo_sa" {
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

resource "kubernetes_secret" "db-secret" {
  metadata {
    name = "db-secret"
  }

  data = {
    username = "postgres"
    password = "Sup3rS3cret!"
    database = "demo"
  }
}

resource "google_project_iam_binding" "sql-admin-binding" {
  project = var.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${google_service_account.postgres_springboot_demo_sa.email}",
  ]
}
resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.postgres_springboot_demo_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[default/${kubernetes_service_account.kubernetes_sa.metadata[0].name}]",
  ]
}

// Ingress controller that passes traffic to the internal load balancer that sends traffic to the application itself.
// Also where we define the managed cert it will use for https
resource "kubernetes_ingress_v1" "ingress" {
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

// Internal load balancer that sends traffic to the Vote-App
resource "kubernetes_service" "lb" {
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
resource "kubernetes_deployment" "spring-boot-demo" {
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
          image = "us-west1-docker.pkg.dev/cci-sandbox-danial/spring-boot-demo-repo/spring-boot-demo:v3"
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





