output "gcp_project_id" {
  value = var.gcp_project_id
}

output "gcp_region" {
  value = var.gcp_region
}

output "gke_cluster_endpoint" {
  value     = module.gke_vault_demo.endpoint
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = base64decode(module.gke_vault_demo.ca_certificate)
  sensitive = true
}

output "cluster_name" {
  value = module.gke_vault_demo.name
}

output "vault_cluster_sa" {
  value = google_service_account.vault_server_sa.email
}

# output "snapshot_bucket_name" {
#   value = google_storage_bucket.vault_snapshot_bucket.name
# }
#
output "vault_keyring" {
  value = google_kms_key_ring.vault_keyring.name
}

output "vault_unseal_keyname" {
  value = google_kms_crypto_key.vault_auto_unseal_key.name
}
