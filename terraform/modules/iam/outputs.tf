output "service_account_email" {
  description = "The email of the service account"
  value       = google_service_account.github_actions.email
}

output "service_account_key" {
  description = "The private key for the service account (base64 encoded)"
  value       = base64decode(google_service_account_key.github_actions_key.private_key)
  sensitive   = true
} 