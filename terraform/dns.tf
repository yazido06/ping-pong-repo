resource "google_dns_managed_zone" "ping_pong" {
  name        = "ping-pong-zone"
  dns_name    = "yazidgoghrod.com."
  description = "DNS zone for ping-pong application"
  visibility  = "public"
}

# Create A record for the application
resource "google_dns_record_set" "ping_pong" {
  name         = "ping-pong.${google_dns_managed_zone.ping_pong.dns_name}"
  managed_zone = google_dns_managed_zone.ping_pong.name
  type         = "A"
  ttl          = 300
} 