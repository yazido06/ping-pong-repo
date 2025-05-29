FROM ubuntu:22.04

# Define build arguments for all tool versions
ARG TERRAFORM_VERSION=1.12.1
ARG KUBECTL_VERSION=1.33.0
ARG HELM_VERSION=3.18.0

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic requirements
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    gnupg \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install Google Cloud SDK and GKE auth plugin
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update \
    && apt-get install -y google-cloud-cli google-cloud-sdk-config-connector google-cloud-sdk-gke-gcloud-auth-plugin

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install Helm
RUN curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar -xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm -rf linux-amd64 helm-v${HELM_VERSION}-linux-amd64.tar.gz

# Install Terraform
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install additional useful tools
RUN apt-get update && apt-get install -y \
    jq \
    vim \
    htop \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /workspace

# Create a non-root user
RUN useradd -ms /bin/bash devuser \
    && chown -R devuser:devuser /workspace

# Create Helm config directory and set permissions
RUN mkdir -p /home/devuser/.config/helm \
    && chown -R devuser:devuser /home/devuser/.config

# Switch to non-root user
USER devuser

# Set up shell environment
RUN echo 'export PS1="\[\033[01;32m\]\u@dev-container\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> ~/.bashrc

# Set up GCP authentication
ENV USE_GKE_GCLOUD_AUTH_PLUGIN=True
COPY --chown=devuser:devuser scripts/local_gcp_auth.sh /home/devuser/scripts/
RUN chmod +x /home/devuser/scripts/local_gcp_auth.sh \
    && echo ". /home/devuser/scripts/local_gcp_auth.sh" >> ~/.bashrc

# Set default command
CMD ["/bin/bash"]
