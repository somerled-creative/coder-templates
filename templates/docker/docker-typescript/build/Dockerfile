FROM debian:bullseye

SHELL ["/bin/bash", "-c"]

# Install baseline packages
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
      bash \
      build-essential \
      curl \
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

# Set the locale
RUN sed -i "/en_US.UTF-8/s/^# //g" /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ARG USERNAME=coder
RUN useradd ${USERNAME} \
      --create-home \
      --shell=/usr/bin/zsh \
      --uid=1000 \
      --user-group \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}
