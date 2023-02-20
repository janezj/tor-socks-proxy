FROM debian:bullseye-backports

LABEL maintainer="Peter Dave Hello <hsu@peterdavehello.org>"
LABEL name="tor-socks-proxy"
LABEL version="latest"

RUN echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tor obfs4proxy curl && \
    chmod 700 /var/lib/tor && \
    rm -rf /var/lib/apt/lists/* && \
    tor --version

# Create a user with the same UID and GID as the tor user inside the container
RUN groupadd -g 1000 tor && \
    useradd -u 1000 -g 1000 -s /bin/false tor && \
    chown tor:tor /etc/tor
COPY torrc /etc/tor/
RUN chown tor:tor /etc/tor/torrc /var/lib/tor

HEALTHCHECK --timeout=10s --start-period=60s \
    CMD curl --fail --socks5-hostname localhost:9150 -I -L 'https://www.facebookwkhpilnemxj7asaniu7vnjjbiltxjqhye3mhbshg7kx5tfyd.onion/' || exit 1

USER tor
EXPOSE 8853/udp 9150/tcp

CMD ["/usr/bin/tor", "-f", "/etc/tor/torrc"]
