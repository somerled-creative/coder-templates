# [Choice] Node.js version:
# - 18-bullseye
# - 16-bullseye
# - 14-bullseye

ARG VARIANT=18-bullseye
FROM node:${VARIANT}

COPY scripts/*.sh scripts/*.env /usr/local/share/setup/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Install python-is-python3 on bullseye to prevent node-gyp regressions
    && . /etc/os-release \
    && apt-get -y install --no-install-recommends python-is-python3 \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /root/.gnupg
