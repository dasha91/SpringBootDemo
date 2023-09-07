terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.27.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

provider "kubernetes" {
  host = google_container_cluster.gke.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
  client_key             = google_container_cluster.gke.master_auth.0.client_key
  client_certificate     = google_container_cluster.gke.master_auth.0.client_certificate
}

# Retrieve GKE cluster information
provider "google" {
  project = var.project_id
  region  = var.region
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "zone" {
  description = "zone"
}