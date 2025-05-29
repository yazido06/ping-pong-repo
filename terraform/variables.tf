variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west1"
}

variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "ping-pong-vpc"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "ping-pong-cluster"
}

variable "service_account_email" {
  description = "The service account email for the GKE nodes"
  type        = string
  default     = null
}

variable "node_pools" {
  description = "List of node pools to be created"
  type = list(object({
    name         = string
    machine_type = string
    min_count    = number
    max_count    = number
    disk_size_gb = number
  }))
  default = [
    {
      name         = "default-pool"
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 1
      disk_size_gb = 20
    }
  ]
}

variable "node_pools_labels" {
  description = "Map of labels to be applied to node pools"
  type        = map(map(string))
  default = {
    "default-pool" = {
      "environment" = "production"
    }
  }
}

variable "node_pools_tags" {
  description = "Map of network tags to be applied to node pools"
  type        = map(list(string))
  default = {
    "default-pool" = ["gke-node", "ping-pong-node"]
  }
} 