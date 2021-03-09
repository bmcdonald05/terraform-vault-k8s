#Vault Audit Methods
#   It is highly recommended to enable two(2) audit devices.
#   If auditing is enabled and cannot write to anything, Vault will become unresponsive.

data "kubernetes_secret" "token_review_jwt" {
  metadata {
    name      = "vault-auth"
    namespace = var.vault_namespace
  }
}

resource "vault_audit" "vault_file_audit" {
  type = "file"
  path = "file"

  options = {
    file_path = "/vault/audit/vault_logs.log"
  }
}
# This is a workaround for a "syslog equivilent" on conatiners
resource "vault_audit" "vault_stdout_file_audit" {
  type = "file"
  path = "stdout"

  options = {
    file_path = "stdout"
  }
}

# Enable KV-v2 secrets engine at root level
resource "vault_mount" "kv2" {
  path        = "secret"
  type        = "kv-v2"
  description = "This is a standard mount for kv version 2"
}

#Enable k8 Auth Method
module "k8_auth" {
  source     = "./modules/k8_auth"
  count                = var.bootstrap ? 0 : 1
  # Does not seem to work anymore
  # depends_on = [kubernetes_secret.vault_auth_token, vault_mount.kv2]

  k8_auth_backend_path = "kubernetes/${data.terraform_remote_state.gke_cluster.outputs.cluster_name}"      #Vault Path for Auth Backend
  k8_endpoint_url      = "https://${data.terraform_remote_state.gke_cluster.outputs.gke_cluster_endpoint}" # K8s endpoint url
  k8_cluster_ca        = data.terraform_remote_state.gke_cluster.outputs.cluster_ca_certificate            # K8s cluster certificate
  token_reviewer_jwt   = data.kubernetes_secret.token_review_jwt.data["token"]                             # A service account JWT used to access the TokenReview API to validate other JWTs during login.
  create_default_role  = true                                                                              # Boolean value to create k8 role with module (default: false)


  # Additional required values if you enable the default role
  role_name           = "k8_demo"                                                # Name for the role
  bound_sa_names      = [kubernetes_service_account.vault_auth.metadata[0].name] # List of k8s service account names allowed to access role. Can only be set to ["*"] if bound_sa_namespaces is NOT set to ["*"]
  bound_sa_namespaces = ["*"]                                                    # List of namespaces allowed to access this role. Can only be set to ["*"] if bound_sa_names is NOT set to ["*"]
  token_ttl           = 43200                                                    # Incremental lifetime for generated tokens in seconds (default: 3600 seconds)
  token_policies      = ["default", "k8s_sa_policy"]                             # List of Vault policies to attach to token
}

resource "vault_generic_secret" "secret_1" {
  depends_on = [vault_mount.kv2]
  path       = "secret/hello-world"

  data_json = <<EOT
{
  "my-secret": "I just injected a secret"
}
EOT
}

resource "vault_generic_secret" "secret_2" {
  depends_on = [vault_mount.kv2]
  path       = "secret/secret1"

  data_json = <<EOT
{
  "foo": "bar",
  "color": "green",
  "year": "2021"
}
EOT
}

resource "vault_generic_secret" "secret_3" {
  depends_on = [vault_mount.kv2]
  path       = "secret/secret2"

  data_json = <<EOT
{
  "username": "user1",
  "password": "SuperSecret1"
}
EOT
}
