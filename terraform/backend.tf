terraform {
  backend "gcs" {
    bucket = "ping-pong-terraform-state-20250528"
    prefix = "terraform/state"
  }
} 