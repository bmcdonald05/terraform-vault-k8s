resource "vault_kubernetes_auth_backend_role" "k8_auth_default_role" {

  backend                          = var.k8_auth_path
  role_name                        = var.default_role_name
  bound_service_account_names      = var.bound_sa_names      #List of service account names able to access this role. If set to ["*"] all names are allowed, both this and bound_service_account_namespaces can not be "*".
  bound_service_account_namespaces = var.bound_sa_namespaces #List of namespaces allowed to access this role. If set to ["*"] all namespaces are allowed, both this and bound_service_account_names can not be set to "*".
  token_ttl                        = var.token_ttl
  token_policies                   = var.token_policies
}
