locals {
  vault_values = {
    gcp_project_id       = var.gcp_project_id
    gcp_region           = var.gcp_region
    gke_cluster_sa       = data.terraform_remote_state.gke_cluster.outputs.vault_cluster_sa
    vault_version        = var.vault_version
    vault_namespace      = var.vault_namespace
    k8s_vault_sa_name    = var.k8s_vault_sa_name
    vault_keyring        = data.terraform_remote_state.gke_cluster.outputs.vault_keyring
    vault_unseal_keyname = data.terraform_remote_state.gke_cluster.outputs.vault_unseal_keyname
    num_replicas         = 3
  }
}

resource "helm_release" "vault" {
  repository       = "https://helm.releases.hashicorp.com/"
  version          = "0.9.0"
  name             = "vault"
  chart            = "vault"
  create_namespace = true
  namespace        = var.vault_namespace

  values = [
    templatefile("override-values.yaml", local.vault_values)
  ]

  #Helpful to help with applying changes to pods as they are set to "OnDelete" by default
  recreate_pods = true
}
