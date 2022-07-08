data "google_client_config" "default" {}

module "primary" {
  source                 = "./modules/instance"
  name                   = "isidro-us"
  vpc                    = google_compute_network.isidro.name
  auxiliary_range        = "172.16.0.0/18"
  pods_range             = "172.16.64.0/19"
  services_range         = "172.16.96.0/19"
  region                 = "us-central1"
  node_count             = 1
  nodes_service_account  = google_service_account.nodes.email
  spot                   = false
  machine_type           = "n2d-standard-2"
  binauthz_attestor_name = google_binary_authorization_attestor.isidro.name
  providers = {
    kubernetes = kubernetes.primary
  }
}

provider "kubernetes" {
  alias                  = "primary"
  host                   = "https://${module.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.primary.ca_certificate)
}

module "secondary" {
  source                 = "./modules/instance"
  name                   = "isidro-fi"
  vpc                    = google_compute_network.isidro.name
  auxiliary_range        = "172.16.128.0/18"
  pods_range             = "172.16.192.0/19"
  services_range         = "172.16.224.0/19"
  region                 = "europe-north1"
  node_count             = 1
  nodes_service_account  = google_service_account.nodes.email
  spot                   = false
  machine_type           = "n2d-standard-2"
  binauthz_attestor_name = google_binary_authorization_attestor.isidro.name
  providers = {
    kubernetes = kubernetes.secondary
  }
}

provider "kubernetes" {
  alias                  = "secondary"
  host                   = "https://${module.secondary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.secondary.ca_certificate)
}

module "tertiary" {
  source                 = "./modules/instance"
  name                   = "isidro-br"
  vpc                    = google_compute_network.isidro.name
  auxiliary_range        = "172.17.128.0/18"
  pods_range             = "172.17.192.0/19"
  services_range         = "172.17.224.0/19"
  region                 = "southamerica-east1"
  node_count             = 1
  nodes_service_account  = google_service_account.nodes.email
  spot                   = false
  machine_type           = "n2d-standard-2"
  binauthz_attestor_name = google_binary_authorization_attestor.isidro.name
  providers = {
    kubernetes = kubernetes.tertiary
  }
}

provider "kubernetes" {
  alias                  = "tertiary"
  host                   = "https://${module.tertiary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.tertiary.ca_certificate)
}

module "config" {
  source                 = "./modules/instance"
  name                   = "isidro-config"
  vpc                    = google_compute_network.isidro.name
  auxiliary_range        = "172.17.0.0/18"
  pods_range             = "172.17.64.0/19"
  services_range         = "172.17.96.0/19"
  region                 = "northamerica-northeast1"
  node_count             = 1
  nodes_service_account  = google_service_account.nodes.email
  spot                   = false
  machine_type           = "n2d-standard-2"
  binauthz_attestor_name = google_binary_authorization_attestor.isidro.name
  providers = {
    kubernetes = kubernetes.config
  }
}

provider "kubernetes" {
  alias                  = "config"
  host                   = "https://${module.config.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.config.ca_certificate)
}

resource "google_gke_hub_feature" "mci" {
  depends_on = [
    module.config
  ]
  name     = "multiclusteringress"
  location = "global"
  spec {
    multiclusteringress {
      config_membership = "projects/${data.google_project.project.project_id}/locations/global/memberships/${module.config.name}-membership"
    }
  }
  provider = google-beta
}