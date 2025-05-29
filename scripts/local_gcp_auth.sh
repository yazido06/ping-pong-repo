#!/bin/bash

# FOR LOCAL USE ONLY

# This script helps you authenticating to the GCP cluster and getting a kube config file.
# Source it in your current shell with the command ". scripts/local_gcp_auth.sh".

## Usage
# - Call the function gkeKubeAuth to authenticate to the GKE cluster.
# -- You can now use kubectl and helm commands authenticated towards your GKE cluster.
# - Call the function gcpTfAuth to enable Terraform to login towards your GCP project.
# - Call the function gcpFullAuth to enable both GKE and Terraform access.

## Utility functions
##
installGkeAuthPlugin() {
  if ! command -v gke-gcloud-auth-plugin &> /dev/null; then
    echo "Installing gke-gcloud-auth-plugin..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates gnupg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin
  fi
}

gcloudAuth() {
  gcloud auth login
  gcloud config set project $GCP_PROJECT_ID
}

gcloudAppAuth() {
  # Needs gcloudAuth to be called first
  gcloud auth application-default login
}

## User friendly functions
##
gkeKubeAuth() {
  installGkeAuthPlugin
  gcloudAuth
  gcloud container clusters get-credentials $K8S_CLUSTER_NAME --region $GCP_REGION
}

gcpTfAuth() {
  gcloudAuth
  gcloudAppAuth
}

gcpFullAuth() {
  installGkeAuthPlugin
  gkeKubeAuth
  gcloudAppAuth
}

if [ -n "${DEFAULT_AUTH}" ]; then
  echo "Authenticating using default auth: ${DEFAULT_AUTH}"
  eval "${DEFAULT_AUTH}"
fi 