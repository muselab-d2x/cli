FROM heroku/heroku:22

ENV DEBIAN_FRONTEND=noninteractive

# This will typically be nightly
ARG SF_CLI_VERSION=nightly
# Full semver version with `v` prefix. e.g. v20.9.0
ARG NODE_VERSION
# sha256 checksum for the nodejs.tar.gz file
ARG NODE_CHECKSUM

RUN echo "${NODE_CHECKSUM}  ./nodejs.tar.gz" > node-file-lock.sha \
  && curl -s -o nodejs.tar.gz https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz \
  && shasum --check node-file-lock.sha
RUN mkdir /usr/local/lib/nodejs \
  && tar xf nodejs.tar.gz -C /usr/local/lib/nodejs/ --strip-components 1 \
  && rm nodejs.tar.gz node-file-lock.sha

ENV PATH=/usr/local/lib/nodejs/bin:$PATH
RUN npm install --global @salesforce/cli@${SF_CLI_VERSION}

RUN apt-get update && apt-get install --assume-yes openjdk-11-jdk-headless jq
RUN apt-get autoremove --assume-yes \
  && apt-get clean --assume-yes \
  && rm -rf /var/lib/apt/lists/*

ENV SF_CONTAINER_MODE true
ENV SFDX_CONTAINER_MODE true
ENV DEBIAN_FRONTEND=dialog
ENV SHELL /bin/bash

# Add QEMU installation step to enable multi-arch support
RUN apt-get update && apt-get install -y qemu-user-static

# Add --platform flag to docker build command to specify target architectures
# This is typically done in the build command, not in the Dockerfile itself
# Example: docker buildx build --platform linux/amd64,linux/arm64 -t myimage:latest .

# Update SF_CLI_VERSION argument to use the latest version by default
ARG SF_CLI_VERSION=latest
