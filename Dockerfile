FROM debian:stable-slim

ENV URL_XDECO_DOWNLOAD="http://xdeco.org/?page_id=30"

COPY imagebuildscripts/install_modesmixer2.sh /tmp/install_modesmixer2.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        netbase \
        git \
        build-essential \
        && \
    # Install DMTCP
    git clone https://github.com/dmtcp/dmtcp.git /src/dmtcp && \
    ./configure && \
    make && \
    make install && \
    apt-get remove -y \
        git \
        build-essential \
        && \
    # Install ModeSMixer2 and get version
    bash -x /tmp/install_modesmixer2.sh && \
    modesmixer2 --help | head -1 >> /VERSIONS || true && \
    # Clean up
    apt-get remove -y \
        ca-certificates \
        curl \
        file \
        && \
    apt-get autoremove -y && \
    apt-get clean -y
    #rm -rf /var/lib/apt/lists/* /tmp/* && \
    #find /var/log -type f -exec truncate -s 0 {} \;
    # Finish
    #modesmixer2 --help > /dev/null 2>&1 && \
    #cat /VERSIONS

ENTRYPOINT [ "/usr/local/bin/dmtcp_launch" ]

CMD [ "--no-coordinator", "--no-gzip", "--ckptdir", "/data", "--modity-env", "/usr/local/bin/modesmixer2" ]

