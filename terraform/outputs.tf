output "github_actions_service_account_email" {
  description = "The email of the GitHub Actions service account"
  value       = module.github_actions.service_account_email
}

output "github_actions_service_account_key" {
  description = "The private key for the GitHub Actions service account (base64 encoded)"
  value       = module.github_actions.service_account_key
  sensitive   = true
}

output "dns_nameservers" {
  description = "The nameservers for the DNS zone"
  value       = google_dns_managed_zone.ping_pong.name_servers
}

output "dns_zone_name" {
  description = "The name of the DNS zone"
  value       = google_dns_managed_zone.ping_pong.name
} 