terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~>2.18"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
  }
}

# For this method, a Vault Token is reguired for Terraform to authenticate.
# You can set the VAULT_TOKEN via the VAULT_TOKEN environment variable. "export VAULT_TOKEN=<token-here>"
# If no token is otherwise supplied, Terraform will attempt to read it from ~/.vault-token (where the vault command stores its current token).
# Terraform will issue itself a new token that is a child of the one given, with a short TTL to limit the exposure of any requested secrets.
# Note that the given token must have the update capability on the auth/token/create path in Vault in order to create child tokens.

provider "vault" {
  address         = var.vault_cluster_addr
  skip_tls_verify = true #if TLS has not been setup
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
