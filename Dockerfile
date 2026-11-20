FROM postgres:14

ARG BASE_DIGEST
LABEL org.opencontainers.image.base.name="docker.io/library/postgres:14" \
      org.opencontainers.image.base.digest="${BASE_DIGEST}"

# VectorChord's upstream PG14 amd64 Debian release, verified before installation.
ARG VCHORD_VERSION=1.1.1
ARG VCHORD_SHA256=5d2cbceac11acb7f0da2f27d3d0e2d3a0698485e5b674047e8255c5a075841a9

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates curl \
        postgresql-14-cron \
        postgresql-14-pgvector; \
    curl --fail --location --show-error --silent \
        "https://github.com/tensorchord/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-14-vchord_${VCHORD_VERSION}-1_amd64.deb" \
        --output /tmp/vchord.deb; \
    echo "${VCHORD_SHA256}  /tmp/vchord.deb" | sha256sum --check; \
    apt-get install -y --no-install-recommends /tmp/vchord.deb; \
    rm -f /tmp/vchord.deb; \
    rm -rf /var/lib/apt/lists/*

# Keep the official entrypoint, PGDATA, and data volume unchanged.
CMD ["postgres", "-c", "shared_preload_libraries=pg_cron,vchord.so"]
