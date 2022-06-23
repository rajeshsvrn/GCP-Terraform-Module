#Creating VPC

resource "google_compute_network" "network" {
  name                            = var.network_name
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  project                         = var.project_id
}

#Creating Subnet

resource "google_compute_subnetwork" "public-subnetwork" {
name = "terraform-subnetwork"
ip_cidr_range = "10.2.0.0/16"
#region = var.region
network = google_compute_network.network.name
}

# reserved IP address
resource "google_compute_global_address" "default" {
  provider = google-beta
  name = "tcp-proxy-xlb-ip"
}
