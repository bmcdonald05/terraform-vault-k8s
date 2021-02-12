terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0.2"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

data "google_client_config" "provider" {}

data "terraform_remote_state" "gke_cluster" {
  backend = "local"

  config = {
    path = "../vault-gke-cluster/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.gke_cluster.outputs.gke_cluster_endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = data.terraform_remote_state.gke_cluster.outputs.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.terraform_remote_state.gke_cluster.outputs.gke_cluster_endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = data.terraform_remote_state.gke_cluster.outputs.cluster_ca_certificate
  }
}
