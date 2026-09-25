FROM postgres:14

ARG BASE_DIGEST
LABEL org.opencontainers.image.base.name="docker.io/library/postgres:14" \
      org.opencontainers.image.base.digest="${BASE_DIGEST}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-14-cron \
    && rm -rf /var/lib/apt/lists/*

# Keep the official entrypoint, PGDATA, and data volume unchanged.
CMD ["postgres", "-c", "shared_preload_libraries=pg_cron"]
