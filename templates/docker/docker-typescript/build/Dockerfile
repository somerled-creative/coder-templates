# [Choice] Node.js version:
# - 18-bullseye
# - 16-bullseye
# - 14-bullseye

ARG VARIANT=18-bullseye
FROM thewidgetsmith/coder-js-node:${VARIANT}

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"

# Set username info
ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ARG NPM_GLOBAL=/usr/local/share/npm-global

ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NPM_GLOBAL}/bin:${NVM_DIR}/current/bin:${PATH}

# Install common packages, non-root user, install nvm
RUN bash /usr/local/share/setup/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    # Install nvm
    && bash /usr/local/share/setup/node-debian.sh "${NVM_DIR}" "none" "${USERNAME}" \
    # Configure global npm install location, use group to adapt to UID/GID changes
    && if ! cat /etc/group | grep -e "^npm:" > /dev/null 2>&1; then groupadd -r npm; fi \
    && usermod -a -G npm ${USERNAME} \
    && umask 0002 \
    && mkdir -p ${NPM_GLOBAL} \
    && touch /usr/local/etc/npmrc \
    && chown ${USERNAME}:npm ${NPM_GLOBAL} /usr/local/etc/npmrc \
    && chmod g+s ${NPM_GLOBAL} \
    && npm config -g set prefix ${NPM_GLOBAL} \
    && sudo -u ${USERNAME} npm config -g set prefix ${NPM_GLOBAL} \
    # Install eslint
    && su ${USERNAME} -c "umask 0002 && npm install -g eslint" \
    && npm cache clean --force > /dev/null 2>&1

# Install tslint, typescript. eslint is installed by javascript image
ARG NODE_MODULES="tslint-to-eslint-config typescript"
RUN su ${USERNAME} -c "umask 0002 && npm install -g ${NODE_MODULES}" \
    && npm cache clean --force > /dev/null 2>&1

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment if you want to install an additional version of node using nvm
# ARG EXTRA_NODE_VERSION=10
# RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node modules
# RUN su node -c "npm install -g <your-package-list-here>""

USER ${USERNAME}
WORKDIR /home/${USERNAME}
