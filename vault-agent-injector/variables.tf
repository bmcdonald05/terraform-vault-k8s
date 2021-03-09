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

variable "vault_namespace" {
  type        = string
  description = "Name of kubernetes namespace to deploy Vault to"
  default     = ""
}

variable "k8s_vault_sa_name" {
  type        = string
  description = "Name of kubernetes SA for Vault service to utilize"
  default     = ""
}

variable "vault_cluster_addr" {
  type        = string
  description = "Endpoint to reach the Vault cluster service"
  default     = ""
}

variable "bootstrap" {
  type        = bool
  description = "Boolean value to indicate if this is the first run or not"
  default     = true
}
