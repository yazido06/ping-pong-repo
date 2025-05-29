#!/bin/bash

# Exit on error
set -e

# Variables
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="ping-pong-terraform-state-20250528"
LOCATION="europe-west1"
CURRENT_USER=$(gcloud config get-value account)

# Create GCS bucket if it doesn't exist
if ! gsutil ls "gs://${BUCKET_NAME}" >/dev/null 2>&1; then
    echo "Creating GCS bucket: ${BUCKET_NAME}"
    gsutil mb -p "${PROJECT_ID}" -l "${LOCATION}" "gs://${BUCKET_NAME}"
    gsutil versioning set on "gs://${BUCKET_NAME}"
fi

# Grant necessary IAM permissions
echo "Granting IAM permissions for ${CURRENT_USER}"
gsutil iam ch "user:${CURRENT_USER}:roles/storage.admin" "gs://${BUCKET_NAME}"

# Initialize Terraform
terraform init 