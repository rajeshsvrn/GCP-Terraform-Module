output "network" {
  value       = google_compute_network.network
  description = "The VPC resource being created"
}

output "network_name" {
  value       = google_compute_network.network.name
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = google_compute_network.network.id
  description = "The ID of the VPC being created"
}

output "subnet_id" {
    value = google_compute_subnetwork.public-subnetwork.id
  
}

output "global_address" {
    value = google_compute_global_address.default.id
  
}
