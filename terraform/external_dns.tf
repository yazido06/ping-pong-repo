resource "google_service_account" "external_dns" {
  account_id   = "external-dns"
  display_name = "External DNS Service Account"
  description  = "Service account for External DNS"
}

resource "google_project_iam_member" "external_dns_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns.email}"
}

resource "google_service_account_key" "external_dns" {
  service_account_id = google_service_account.external_dns.name
}

output "external_dns_key" {
  description = "The private key for the External DNS service account (base64 encoded)"
  value       = google_service_account_key.external_dns.private_key
  sensitive   = true
} 