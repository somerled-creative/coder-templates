FROM thewidgetsmith/coder-dind-debian:bookworm

# Add a user
ARG USERNAME=coder
RUN useradd ${USERNAME} \
      --create-home \
      --shell=/usr/bin/zsh \
      --groups=docker \
      --uid=1000 \
      --user-group \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}
