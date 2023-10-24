FROM ubuntu:jammy

SHELL ["/bin/bash", "-c"]

# Install the Docker apt repository
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get upgrade --yes && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
    	ca-certificates \
	curl \
	gnupg &&\
    install -m 0755 -d /etc/apt/keyrings

COPY docker.gpg /etc/apt/keyrings/docker.gpg
COPY docker.list /etc/apt/sources.list.d/docker.list
RUN chmod a+r /etc/apt/keyrings/docker.gpg

# Install baseline packages
# Install latest Git using their official PPA
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
      bash \
      build-essential \
      docker-buildx-plugin \
      docker-ce \
      docker-ce-cli \
      docker-compose-plugin \
      fonts-firacode \
      fonts-inconsolata \
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
      zsh && \
    add-apt-repository ppa:git-core/ppa && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes git && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Enables Docker starting with systemd
RUN systemctl enable docker

# Make typing unicode characters in the terminal work.
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen "en_US.UTF-8"
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LANG en_US.UTF-8

