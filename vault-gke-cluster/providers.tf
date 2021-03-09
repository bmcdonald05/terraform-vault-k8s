terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.55.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.49.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# data "google_client_config" "default" {}
#
# provider "kubernetes" {
#   load_config_file       = false
#   host                   = "https://${module.gke_vault_demo.endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(module.gke_vault_demo.ca_certificate)
# }
