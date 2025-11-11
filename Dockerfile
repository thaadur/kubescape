# ==========================================================
#  SecureCloud - Kubescape (KSPM) Unified Image
#  Maintained by: lokeshtk / SecureCloud_PWN
#  Source: https://github.com/thaadur/kubescape.git
# ==========================================================

FROM ubuntu:22.04

LABEL maintainer="SecureCloud <SecureCloud_PWN>"
LABEL org.opencontainers.image.source="https://github.com/thaadur/kubescape"
LABEL description="SecureCloud Kubescape KSPM Scanner"

ARG GIT_USER=thaadur
ARG GIT_TOKEN

# ----------------------------------------------------------
# Install base dependencies
# ----------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git unzip ca-certificates gnupg jq && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------
# Create working directory
# ----------------------------------------------------------
WORKDIR /opt/kubescape

# ----------------------------------------------------------
# Clone Kubescape source (from private GitHub repo)
# ----------------------------------------------------------
# To build with private access:
# docker build --build-arg GIT_TOKEN=<your_token> -t lokeshtk/kubescape:latest -f Dockerfile.kubescape .
RUN if [ -n "$GIT_TOKEN" ]; then \
      git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/${GIT_USER}/kubescape.git /opt/kubescape; \
    else \
      git clone https://github.com/${GIT_USER}/kubescape.git /opt/kubescape; \
    fi

# ----------------------------------------------------------
# Install Kubescape binary (latest stable)
# ----------------------------------------------------------
RUN curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | bash && \
    mv /usr/local/bin/kubescape /usr/bin/kubescape && \
    kubescape version || true

# ----------------------------------------------------------
# Verify installation
# ----------------------------------------------------------
RUN echo "✅ Kubescape Installed Successfully" && kubescape version

# ----------------------------------------------------------
# Add consistent non-root user
# ----------------------------------------------------------
RUN addgroup --gid 1000 securecloud && \
    adduser --uid 1000 --gid 1000 --disabled-password --gecos "" securecloud
USER securecloud
WORKDIR /home/securecloud

# ----------------------------------------------------------
# Entrypoint
# ----------------------------------------------------------
ENTRYPOINT ["kubescape"]
CMD ["scan", "--help"]
