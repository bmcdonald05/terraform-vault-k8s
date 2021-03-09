module "gke_vault_demo" {
  # source                   = "terraform-google-modules/kubernetes-engine/google//examples/simple_regional_beta"
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster-update-variant"
  project_id             = var.gcp_project_id
  name                   = var.name_prefix
  regional               = false
  region                 = var.gcp_region
  zones                  = var.gcp_zones
  network                = var.network
  subnetwork             = var.subnetwork
  ip_range_pods          = var.ip_range_pods
  ip_range_services      = var.ip_range_services
  create_service_account = false
  # service_account          = var.compute_engine_service_account
  service_account          = google_service_account.vault_server_sa.email
  istio                    = false
  cloudrun                 = false
  dns_cache                = false
  gce_pd_csi_driver        = true
  sandbox_enabled          = false
  remove_default_node_pool = true
  release_channel          = "REGULAR"

  # utilize workload identity
  node_metadata = "GKE_METADATA_SERVER"

  node_pools = [
    {
      name         = "${var.name_prefix}-node-pool"
      machine_type = var.node_pool_machine_type
      autoscaling  = false
      auto_repair  = true
      auto_upgrade = true
      # service_account    = var.compute_engine_service_account
      service_account    = google_service_account.vault_server_sa.email
      initial_node_count = 1
      node_count         = var.gke_num_nodes
    },
  ]

  node_pools_labels = {
    all = {
      env     = var.gcp_project_id,
      purpose = "vault-demo"
    }
  }
}
