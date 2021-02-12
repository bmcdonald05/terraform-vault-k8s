resource "kubernetes_service_account" "vault_auth" {

  metadata {
    name      = "vault-auth"
    namespace = var.vault_namespace
  }

}

resource "kubernetes_secret" "vault_auth_token" {

  metadata {
    name      = "vault-auth"
    namespace = var.vault_namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.vault_auth.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding" "vault_auth_binding" {

  metadata {
    name = "role-tokenreview-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_auth.metadata[0].name
    namespace = var.vault_namespace
  }
}
