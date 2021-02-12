variable "k8_auth_backend_path" {
  default = "kubernetes"
}

variable "k8_endpoint_url" {
  default = ""
}

variable "k8_cluster_ca" {
  default = ""
}

variable "token_reviewer_jwt" {
  default = ""
}

variable "create_default_role" {
  default = false
}

variable "role_name" {
  default = "default"
}

variable "bound_sa_names" {
  default = ""
}

variable "bound_sa_namespaces" {
  default = ""
}

variable "token_ttl" {
  default = 3600
}

variable "token_policies" {
  default = ""
}
