provider "kubernetes" {
  alias                  = "secondary"
  host                   = "https://${module.gke_secondary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_secondary.ca_certificate)
}

module "gke_secondary" {
  depends_on                  = [module.gke_primary]
  source                      = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-public-cluster"
  project_id                  = data.google_project.project.project_id
  name                        = var.cluster_name_secondary
  regional                    = true
  region                      = var.region_secondary
  release_channel             = "REGULAR"
  network                     = var.network
  subnetwork                  = var.subnetwork_secondary
  ip_range_pods               = var.ip_range_pods_secondary
  ip_range_services           = var.ip_range_services_secondary
  network_policy              = true
  create_service_account      = false
  service_account             = google_service_account.nodes.email
  enable_binary_authorization = true
  gce_pd_csi_driver           = true
  cluster_resource_labels     = { "mesh_id" : "proj-${data.google_project.project.number}" }
  node_pools = [
    {
      name         = "spot-nodes"
      autoscaling  = false
      auto_upgrade = true
      node_count   = 1
      spot         = true
      machine_type = "e2-standard-2"
    },
    {
      name         = "core-nodes"
      autoscaling  = false
      auto_upgrade = true
      node_count   = 1
      machine_type = "e2-standard-2"
    }
  ]
  node_pools_oauth_scopes = {
    "all" : [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
}

module "asm_secondary" {
  source                    = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/asm"
  cluster_name              = module.gke_secondary.name
  project_id                = data.google_project.project.project_id
  cluster_location          = module.gke_secondary.location
  enable_cni                = true
  enable_fleet_registration = true
  providers = {
    kubernetes = kubernetes.secondary
  }
}