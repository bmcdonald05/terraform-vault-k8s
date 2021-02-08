variable "gcp_project_id" {
  description = "The name of the GCP Project where all resources will be launched."
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "The region in which all GCP resources will be launched."
  type        = string
  default     = "us-east1"
}

variable "name_prefix" {
  description = "A name prefix to easily identify all resources launched with this module."
  type        = string
  default     = "vault-k8s-demo"
}

####New
variable "vault_namespace" {
  type        = string
  description = "Name of kubernetes namespace to deploy Vault to"
  default     = ""
}

variable "vault_version" {
  type        = string
  description = "Version of the Vault binary to install"
  default     = ""
}

variable "k8s_vault_sa_name" {
  type        = string
  description = "Name of kubernetes SA for Vault service to utilize"
  default     = ""
}
