# PostgreSQL 14 with pg_cron

An `amd64` image based on the official `postgres:14`, with `postgresql-14-cron` installed and `pg_cron` preloaded.

**Unraid Repository:** `ghcr.io/neverbolt/postgres-with-pg_cron:14`

GitHub Actions checks the upstream `postgres:14` image daily at 05:17 UTC and rebuilds when its digest changes. Dockerfile and workflow changes also trigger a build. Unraid can check the GHCR tag for updates.

## Switch an existing container

1. Back up the database. Verify your existing data directory is on a persistent host path or named volume, and record the current volume mappings, environment, Post Arguments and ports.
2. Stop the container. Change its Repository from `registry.hub.docker.com/library/postgres:14` to `ghcr.io/neverbolt/postgres-with-pg_cron:14`. **Keep exactly the same mount to `/var/lib/postgresql/data` and any existing `PGDATA` value.** Do not delete the existing volume or create a new directory.
3. Start the container and inspect its logs. This image keeps the official PostgreSQL 14 entrypoint and data location; it uses the already mounted cluster.
4. Connect as superuser to the `postgres` database and run `CREATE EXTENSION IF NOT EXISTS pg_cron;`. Verify with `SHOW shared_preload_libraries;` and `SELECT extversion FROM pg_extension WHERE extname = 'pg_cron';`.

The image's default command preloads `pg_cron`. **If Unraid Post Arguments override that command**, include `-c shared_preload_libraries=pg_cron` there, alongside any existing preloaded libraries. The default scheduling database is `postgres`; set `cron.database_name` before creating the extension in another database.

Publishing only supports `linux/amd64`. GHCR package visibility must be set to public for anonymous Unraid pulls. Verify the first [Actions run](https://github.com/Neverbolt/postgres-with-pg_cron/actions) and package visibility before switching. The image is published at a new GHCR URL; it cannot replace the official Docker Hub image at its existing URL.
