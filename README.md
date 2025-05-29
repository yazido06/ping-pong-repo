# Ping-Pong API DevOps Assessment

This repository contains the infrastructure and deployment configuration for the Ping-Pong API service, demonstrating DevOps best practices and infrastructure-as-code principles.

## Table of Contents

- [1. Prerequisites](#1-prerequisites)
- [2. Clone the Repository](#2-clone-the-repository)
- [3. Configure Environment Variables](#3-configure-environment-variables)
- [4. Start the Development Container](#4-start-the-development-container)
- [5. Authenticate with GCP](#5-authenticate-with-gcp)
- [6. Set up Terraform Variables](#6-set-up-terraform-variables)
- [7. Initialize and Apply Terraform](#7-initialize-and-apply-terraform)
- [8. Set up GitHub Repository Secrets (for CI/CD)](#8-set-up-github-repository-secrets-for-cicd)
- [9. Set Up HTTPS with Let's Encrypt](#9-set-up-https-with-lets-encrypt)
- [10. Set Up ExternalDNS with Google Cloud DNS](#10-set-up-externaldns-with-google-cloud-dns)
- [11. Deploy Application with Helm](#11-deploy-application-with-helm)
- [12. Verify Everything](#12-verify-everything)
- [Advanced/Reference](#advancedreference)

## Project Structure

```
.
├── .github/                    # GitHub Actions workflows
├── docker/                     # Docker configuration
├── kubernetes/                 # Kubernetes manifests and Helm charts
├── scripts/                    # Utility scripts for development and deployment
└── terraform/                  # Terraform configuration for GCP infrastructure
```

### Scripts

The `scripts/` directory contains utility scripts to help with development and deployment tasks:

#### `local_gcp_auth.sh`
A utility script for GCP authentication that provides several functions:

- `gkeKubeAuth`: Authenticates to GKE cluster and configures kubectl
- `gcpTfAuth`: Sets up authentication for Terraform
- `gcpFullAuth`: Sets up both GKE and Terraform authentication

Usage:
```bash
# Source the script in your current shell
. scripts/local_gcp_auth.sh

# Authenticate to GKE cluster
gkeKubeAuth

# Authenticate for Terraform
gcpTfAuth

# Or authenticate for both
gcpFullAuth
```

The script requires these environment variables to be set:
- `GCP_PROJECT_ID`: Your Google Cloud project ID
- `GCP_REGION`: Your GCP region
- `K8S_CLUSTER_NAME`: Your GKE cluster name

## Development Environment

The project includes a development container with all necessary tools pre-installed. This allows you to work on the project without installing any dependencies on your local machine.

### Using the Development Container

1. **Start the container**
   ```bash
   docker-compose up -d
   ```

2. **Access the container**
   ```bash
   docker-compose exec dev bash
   ```

The container includes:
- Terraform (configurable version)
- kubectl
- Helm
- Google Cloud SDK
- Docker CLI
- Git
- Additional development tools (vim, htop, jq)

### Container Features
- Persistent volume mounts for your code
- Access to your local Docker daemon
- Access to your GCP credentials
- Access to your Kubernetes config
- Custom shell prompt for easy identification

### API Endpoints

The Ping-Pong API provides the following endpoints:
- `/ping` - Responds with `{'pong'}`
- `/pong` - Responds with `{'ping'}`
- `/professional-ping-pong` - Responds with `{'pong'}` 90% of the time
- `/amateur-ping-pong` - Responds with `{'pong'}` 70% of the time
- `/chance-ping-pong` - Responds with `{'ping'}` 50% of the time and `{'pong'}` 50% of the time

### Customizing Tool Versions

You can customize the versions of tools used in the container by setting environment variables:

```bash
# Use specific versions
TERRAFORM_VERSION=1.12.1 \
KUBECTL_VERSION=1.33.0 \
HELM_VERSION=3.18.0 \
docker-compose up -d

# Or set them in your environment
export TERRAFORM_VERSION=1.12.1
export KUBECTL_VERSION=1.33.0
export HELM_VERSION=3.18.0
docker-compose up -d
```

Default versions:
- Terraform: 1.12.1
- kubectl: 1.33.0
- Helm: 3.18.0
- Docker CLI: Latest stable version
- Google Cloud CLI: Latest stable version

## 1. Prerequisites

- Docker & Docker Compose installed
- Google Cloud project with required APIs enabled:
  ```bash
  gcloud services enable compute.googleapis.com
  gcloud services enable container.googleapis.com
  gcloud services enable cloudresourcemanager.googleapis.com
  gcloud services enable iam.googleapis.com
  gcloud services enable servicenetworking.googleapis.com
  ```
- GitHub account (for CI/CD)
- (Optional) ghcr.io access for Docker images

## 2. Clone the Repository

```bash
git clone https://github.com/yourusername/ping-pong.git
cd ping-pong
```

## 3. Configure Environment Variables

```bash
cp .env.template .env
# Edit .env with your GCP project, region, and cluster name
```

## 4. Start the Development Container

```bash
docker-compose up -d
docker-compose exec dev bash
```

## 5. Authenticate with GCP

```bash
gcloud auth application-default login
```

## 6. Set up Terraform Variables

```bash
cd terraform
cp terraform.tfvars.template terraform.tfvars
# Edit terraform.tfvars with your values
```

## 7. Initialize and Apply Terraform

```bash
./init.sh
terraform init
terraform plan
terraform apply
```

## 8. Set up GitHub Repository Secrets (for CI/CD)

- Add `GCP_PROJECT_ID` and `GCP_SA_KEY` (from `terraform output github_actions_service_account_key`) as GitHub secrets.

## 9. Set Up HTTPS with Let's Encrypt

1. **Install cert-manager:**
   ```bash
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   helm install cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --create-namespace \
     --version v1.13.3 \
     --set installCRDs=true
   kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=300s
   ```

2. **Install NGINX Ingress Controller:**
   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   helm install ingress-nginx ingress-nginx/ingress-nginx \
     --namespace ingress-nginx \
     --set controller.service.type=LoadBalancer \
     --set controller.minReadySeconds=30 \
     --set controller.progressDeadlineSeconds=600 \
     --create-namespace \
     --version 4.12.2
   ```

3. **Configure Let's Encrypt ClusterIssuer:**
   ```bash
   kubectl apply -f kubernetes/cert-manager-install.yaml
   ```

> **Note:** ExternalDNS will automatically manage the A record for your domain in Google Cloud DNS. Just ensure your domain's nameservers point to your Google Cloud DNS zone.

## 10. Set Up ExternalDNS with Google Cloud DNS

1. **Obtain the service account key:** for ExternalDNS from your Terraform output or Google Cloud Console. The key will be base64-encoded if copied from Terraform output.
   ```bash
   terraform output external_dns_key
   ```
   If the key is base64-encoded, decode it:
   ```bash
   echo '<BASE64_STRING>' | base64 -d > external-dns-key.json
   ```

2. **Create the Kubernetes secret:**
   ```bash
   kubectl create secret generic external-dns-gcp-key --from-file=gcp-key.json=external-dns-key.json -n kube-system
   ```

3. **Apply the ExternalDNS manifest:**
   ```bash
   kubectl apply -f kubernetes/external-dns.yaml
   ```

After ExternalDNS is installed:
- It will automatically create and manage DNS records for your Ingress resources
- DNS records will be updated when the NGINX Ingress Controller's IP changes
- You can verify the DNS records in Google Cloud DNS console

Note: Make sure your domain's nameservers are pointing to Google Cloud DNS. You can get the nameservers using:
```bash
terraform output dns_nameservers
```

## 11. Deploy Application with Helm

```bash
cd kubernetes/helm/ping-pong
helm upgrade --install ping-pong . \
  --set image.tag=latest \
  --set image.repository=ghcr.io/yourusername/ping-pong-repo/ping-pong-api \
  --namespace ping-pong \
  --create-namespace
```

## 12. Verify Everything

- Check DNS records in Google Cloud DNS.
- Check certificate and Ingress status:
  ```bash
  kubectl get certificate -n ping-pong
  kubectl get ingress -n ping-pong
  kubectl get svc -n ingress-nginx
  ```
- Test HTTP and HTTPS access to your domain.

