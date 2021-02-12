resource "vault_auth_backend" "k8_auth" {

  type = "kubernetes"
  path = var.k8_auth_backend_path
}

resource "vault_kubernetes_auth_backend_config" "k8_auth_config" {
  backend            = vault_auth_backend.k8_auth.path
  kubernetes_host    = var.k8_endpoint_url
  kubernetes_ca_cert = var.k8_cluster_ca
  token_reviewer_jwt = var.token_reviewer_jwt

}

resource "vault_kubernetes_auth_backend_role" "k8_auth_default_role" {
  # Make default role optional
  count = var.create_default_role == true ? 1 : 0

  backend                          = vault_auth_backend.k8_auth.path
  role_name                        = var.role_name
  bound_service_account_names      = var.bound_sa_names      #List of service account names able to access this role. If set to ["*"] all names are allowed, both this and bound_service_account_namespaces can not be "*".
  bound_service_account_namespaces = var.bound_sa_namespaces #List of namespaces allowed to access this role. If set to ["*"] all namespaces are allowed, both this and bound_service_account_names can not be set to "*".
  token_ttl                        = var.token_ttl
  token_policies                   = var.token_policies
}
