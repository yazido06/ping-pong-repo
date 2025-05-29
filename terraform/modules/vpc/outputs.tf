output "network" {
  description = "The VPC resource"
  value = google_compute_network.vpc.name
}

output "subnetwork" {
  description = "The subnetwork resource"
  value = google_compute_subnetwork.subnet.name
}

output "ip_range_pods" {
  description = "The secondary IP range used for pods"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].ip_cidr_range
}

output "ip_range_services" {
  description = "The secondary IP range used for services"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].ip_cidr_range
} 
