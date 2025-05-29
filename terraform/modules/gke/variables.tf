variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
}

variable "zones" {
  description = "The zones to deploy nodes to"
  type        = list(string)
  default     = ["europe-west1-b", "europe-west1-c"]
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "network" {
  description = "The VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "service_account_email" {
  description = "The service account email for the GKE nodes"
  type        = string
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
  default = []
}

variable "node_pools_labels" {
  description = "Map of labels to be applied to node pools"
  type        = map(map(string))
  default     = {}
}

variable "node_pools_tags" {
  description = "Map of network tags to be applied to node pools"
  type        = map(list(string))
  default     = {}
} 