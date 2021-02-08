variable "gcp_project_id" {
  description = "The name of the GCP Project where all resources will be launched."
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "The region in which all GCP resources will be launched."
  type        = string
  default     = ""
}

variable "gcp_zones" {
  type        = list(string)
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
  default     = []
}

variable "name_prefix" {
  description = "A name prefix to easily identify all resources launched with this module."
  type        = string
  default     = ""
}

variable "network" {
  type        = string
  description = "The network to place resources in"
  default     = "default"
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork to place resources in"
  default     = ""
}

variable "ip_range_pods" {
  description = "The IP address range for the cluster pod IPs. Set to blank to have a range chosen with the default size. "
  type        = string
  default     = ""
}

variable "ip_range_services" {
  description = "The IP address range of the services IPs in this cluster. Set to blank to have a range chosen with the default size."
  type        = string
  default     = ""
}

variable "node_pool_machine_type" {
  description = "The GCP machine type to use for nodes in the GKE node pool"
  type        = string
  default     = "n1-standard-2"
}

variable "gke_num_nodes" {
  description = "The number of nodes to deploy PER zone in the regional cluster"
  default     = 3
}

variable "compute_engine_service_account" {
  description = "The service account to be used by the Node VMs. If not specified, the 'default' service account is used."
  type        = string
  default     = ""
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
