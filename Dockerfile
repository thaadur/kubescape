# ==========================================================
#  SecureCloud - Kubescape + AWS CLI Unified Image
#  Maintained by: lokeshtk / SecureCloud_PWN
#  Source: https://github.com/thaadur/kubescape.git
# ==========================================================

FROM ubuntu:22.04

LABEL maintainer="SecureCloud <SecureCloud_PWN>"
LABEL org.opencontainers.image.source="https://github.com/thaadur/kubescape"
LABEL description="SecureCloud Kubescape + AWS CLI Image (EKS-ready)"

ARG KUBESCAPE_VERSION=3.0.8
ARG POWERSHELL_VERSION=7.5.0

# ----------------------------------------------------------
# Install base dependencies
# ----------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget unzip ca-certificates jq git gnupg apt-transport-https \
    software-properties-common lsb-release && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------
# Install AWS CLI v2
# ----------------------------------------------------------
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    ln -sf /usr/local/bin/aws /usr/bin/aws && \
    rm -rf /tmp/aws /tmp/awscliv2.zip && \
    aws --version

# ----------------------------------------------------------
# Install Kubescape
# ----------------------------------------------------------
RUN curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash && \
    mv /usr/local/bin/kubescape /usr/bin/kubescape && \
    kubescape version || true

# ----------------------------------------------------------
# (Optional) Install PowerShell (for parity/testing)
# ----------------------------------------------------------
RUN ARCH=$(uname -m) && \
    wget https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-x64.tar.gz -O /tmp/pwsh.tar.gz && \
    mkdir -p /opt/microsoft/powershell/7 && \
    tar zxf /tmp/pwsh.tar.gz -C /opt/microsoft/powershell/7 && \
    chmod +x /opt/microsoft/powershell/7/pwsh && \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh && \
    /opt/microsoft/powershell/7/pwsh --version && \
    rm /tmp/pwsh.tar.gz

# ----------------------------------------------------------
# Add non-root user
# ----------------------------------------------------------
RUN useradd -m -s /bin/bash securecloud
USER securecloud
WORKDIR /home/securecloud

# ----------------------------------------------------------
# Set up environment variables
# ----------------------------------------------------------
ENV HOME=/home/securecloud
ENV PATH="$HOME/.local/bin:$PATH"

# ----------------------------------------------------------
# Verify AWS + Kubescape setup
# ----------------------------------------------------------
RUN echo "🔒 SecureCloud Kubescape Image Verification:" && \
    aws --version && \
    kubescape version && \
    echo "✅ Kubescape + AWS CLI are installed and ready."

# ----------------------------------------------------------
# Default entrypoint
# ----------------------------------------------------------
ENTRYPOINT ["bash", "-c", "echo '🔒 SecureCloud Kubescape Ready ✅'; kubescape \"$@\"", "--"]
