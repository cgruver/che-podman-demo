FROM registry.access.redhat.com/ubi9/ubi-minimal

ARG USER_HOME_DIR="/home/user"
ARG WORK_DIR="/projects"

ENV HOME=${USER_HOME_DIR}
ENV BUILDAH_ISOLATION=chroot

COPY --chown=0:0 entrypoint.sh /

# Note: compat-openssl11 & libbrotli are needed for che-code (Che build of VS Code)

RUN microdnf --disableplugin=subscription-manager install -y openssl compat-openssl11 libbrotli git tar which shadow-utils bash zsh wget jq podman buildah skopeo; \
    microdnf update -y ; \
    microdnf clean all ; \
    mkdir -p ${USER_HOME_DIR} ; \
    mkdir -p ${WORK_DIR} ; \
    chmod +x /entrypoint.sh ; \
    #
    # Setup for root-less podman
    #
    mkdir -p "${HOME}"/.config/containers ; \
    (echo '[storage]';echo 'driver = "vfs"') > "${HOME}"/.config/containers/storage.conf ; \
    setcap cap_setuid+ep /usr/bin/newuidmap ; \
    setcap cap_setgid+ep /usr/bin/newgidmap ; \
    touch /etc/subgid /etc/subuid ; \
    chgrp -R 0 /home ; \
    chmod -R g=u /etc/passwd /etc/group /etc/subuid /etc/subgid /home ${WORK_DIR}

WORKDIR ${WORK_DIR}
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "tail", "-f", "/dev/null" ]
