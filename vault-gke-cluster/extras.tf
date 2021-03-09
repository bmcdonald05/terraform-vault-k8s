#### Create SA account for workload identity
resource "google_service_account" "vault_server_sa" {
  account_id   = "${var.name_prefix}-vault-sa"
  display_name = "Vault Server SA"
}

resource "google_project_iam_custom_role" "vault-custom-role" {
  role_id     = "vaultCustomKMSRole"
  title       = "My Custom Vault Role"
  description = "Custom Role for Vault to use workload identity"
  permissions = ["cloudkms.cryptoKeyVersions.useToEncrypt", "cloudkms.cryptoKeyVersions.useToDecrypt", "cloudkms.cryptoKeys.get"]
}

resource "google_service_account_iam_binding" "vault_workload_identity" {
  service_account_id = google_service_account.vault_server_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[${var.vault_namespace}/${var.k8s_vault_sa_name}]",
  ]
}

resource "google_kms_crypto_key_iam_binding" "vault_sa_crypto_key_binding" {
  crypto_key_id = google_kms_crypto_key.vault_auto_unseal_key.id
  role          = google_project_iam_custom_role.vault-custom-role.id

  members = [
    "serviceAccount:${google_service_account.vault_server_sa.email}",
  ]
}

#### Create a GCP storage bucket to store snapshots ####
# resource "google_storage_bucket" "vault_snapshot_bucket" {
#   name          = "${var.name_prefix}-snapshots"
#   location      = var.gcp_region
#   storage_class = "STANDARD"
#   force_destroy = true
#   #When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run.
#
#   labels = {
#     env = var.gcp_project_id
#   }
# }

#### Create GCP KMS Key and Keyring for auto-unseal ####
#Lifecyle prevent_destroy is included here to prevent issues deleting the key/keyring from state, and the key not being removed from GCP.
#Once removed from state, but not removed from GCP it will give errors for a key with that name already exsisting, and would need to be imported into state.
#This is a limitation in the GCP API/Terraform provider
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring
#
resource "google_kms_key_ring" "vault_keyring" {
  name     = "vault-keyring"
  location = var.gcp_region
  project  = var.gcp_project_id

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "google_kms_crypto_key" "vault_auto_unseal_key" {
  name     = "vault-unseal-key"
  key_ring = google_kms_key_ring.vault_keyring.id
  # rotation_period = "100000s"

  # lifecycle {
  #   prevent_destroy = true
  # }
}
