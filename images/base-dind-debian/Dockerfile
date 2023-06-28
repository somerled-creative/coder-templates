FROM debian:bullseye-slim

SHELL ["/bin/bash", "-c"]

# Install the Docker apt repository
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get upgrade --yes && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes ca-certificates && \
    install -m 0755 -d /etc/apt/keyrings

COPY docker-archive-keyring.gpg /etc/apt/keyrings/docker-archive-keyring.gpg
COPY docker.list /etc/apt/sources.list.d/docker.list
RUN chmod a+r /etc/apt/keyrings/docker-archive-keyring.gpg

# Install baseline packages
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
      bash \
      build-essential \
      curl \
      docker-buildx-plugin \
      docker-ce \
      docker-ce-cli \
      docker-compose-plugin \
      git \
      htop \
      locales \
      man-db \
      rsync \
      software-properties-common \
      sudo \
      systemd \
      systemd-sysv \
      unzip \
      vim \
      wget \
      zsh

# Enables Docker starting with systemd
RUN systemctl enable docker

# Make typing unicode characters in the terminal work.
ENV LANG en_US.UTF-8
