# syntax=docker/dockerfile:1

# Base stage with common settings
FROM heroku/heroku:22 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Trust Heroku's PostgreSQL repository and update GPG keys
RUN apt-get update && apt-get install -y ca-certificates gnupg curl \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xB1998361219BD9C9 \
    && rm -rf /var/lib/apt/lists/*

# Install common dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    openjdk-11-jdk-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Full variant with Node.js and CLI
FROM base AS full
ARG SF_CLI_VERSION
ARG NODE_VERSION
ARG NODE_CHECKSUM

# Set Node.js architecture and download appropriate version
RUN case "$(dpkg --print-architecture)" in \
    'amd64') ARCH_SUFFIX='-x64' ;; \
    'arm64') ARCH_SUFFIX='-arm64' ;; \
    *) echo "Unsupported architecture" && exit 1 ;; \
    esac \
    && curl -s "${DOWNLOAD_URL}${ARCH_SUFFIX}.tar.xz" --output sf-linux.tar.xz \
    && mkdir -p /usr/local/sf \
    && tar xJf sf-linux.tar.xz -C /usr/local/sf --strip-components 1 \
    && rm sf-linux.tar.xz

ENV PATH=/usr/local/lib/nodejs/bin:$PATH

# Install jq and Salesforce CLI
RUN apt-get update && apt-get install -y jq \
    && npm install --global @salesforce/cli@${SF_CLI_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Slim variant with bundled CLI
FROM base AS slim
ARG DOWNLOAD_URL

# Download and install platform-specific CLI bundle
RUN case "$(dpkg --print-architecture)" in \
    'amd64') ARCH_SUFFIX='-x64' ;; \
    'arm64') ARCH_SUFFIX='-arm64' ;; \
    *) echo "Unsupported architecture" && exit 1 ;; \
    esac \
    && curl -s "${DOWNLOAD_URL%x64}${ARCH_SUFFIX}.tar.xz" --output sf-linux.tar.xz \
    && mkdir -p /usr/local/sf \
    && tar xJf sf-linux.tar.xz -C /usr/local/sf --strip-components 1 \
    && rm sf-linux.tar.xz

ENV PATH="/usr/local/sf/bin:$PATH"

# Common environment variables
ENV SF_CONTAINER_MODE=true \
    SFDX_CONTAINER_MODE=true \
    DEBIAN_FRONTEND=dialog \
    SHELL=/bin/bash

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD sf --version >/dev/null 2>&1