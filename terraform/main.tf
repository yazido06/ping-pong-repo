terraform {
  required_version = ">= 1.12.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.37.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network
module "vpc" {
  source = "./modules/vpc"

  project_id = var.project_id
  region     = var.region
  vpc_name   = var.vpc_name
}

# Service Account for GKE
resource "google_service_account" "gke_sa" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
  project      = var.project_id
}

# IAM bindings for the service account
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/container.nodeServiceAccount",
    "roles/storage.objectViewer"
  ])
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# GitHub Actions Service Account
module "github_actions" {
  source = "./modules/iam"

  project_id = var.project_id
}

# GKE Cluster
module "gke" {
  source = "./modules/gke"

  project_id          = var.project_id
  region             = var.region
  zones              = ["europe-west1-b", "europe-west1-c"]
  cluster_name       = var.cluster_name
  network            = module.vpc.network
  subnetwork         = module.vpc.subnetwork
  service_account_email = google_service_account.gke_sa.email
  node_pools_labels  = var.node_pools_labels
  node_pools_tags    = var.node_pools_tags
} 