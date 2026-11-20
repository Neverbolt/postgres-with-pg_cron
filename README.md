# PostgreSQL 14 with pg_cron and VectorChord

An `amd64` image derived from the official `postgres:14`, with `pg_cron`, `pgvector`, and VectorChord 1.1.1 installed. Both `pg_cron` and `vchord.so` are preloaded by default. VectorChord is pinned to its upstream PG14 Debian release and its download is SHA-256 verified.

**Unraid Repository:** `ghcr.io/neverbolt/postgres-with-pg_cron:14`

GitHub Actions checks the upstream `postgres:14` image daily at 05:23 UTC and rebuilds when its digest changes. Dockerfile and workflow changes also trigger a build. A fresh PostgreSQL instance must start and create all three extensions in a smoke test before the new image is published. Unraid can check the GHCR tag for updates. VectorChord is pinned at 1.1.1, so new VectorChord releases require an intentional Dockerfile update.

## Preserve an existing database

This image **does not change PostgreSQL major versions, PGDATA, the official entrypoint, or the inherited data volume**. Installing packages in an image does not migrate or reinitialize an existing cluster. Your data is preserved by reusing **the exact same persistent host path or named volume** at `/var/lib/postgresql/data` (and retaining any custom `PGDATA`). A different or empty mount can appear as a new empty database even though the original data still exists elsewhere.

1. Back up the database and verify that the backup can be read. In Unraid, record the existing repository, volume mappings, `PGDATA` if set, environment variables, ports, and container settings. Confirm that the data directory lives outside the container's writable layer.
2. Stop the PostgreSQL container. Update **only** the Repository field to `ghcr.io/neverbolt/postgres-with-pg_cron:14`. Keep every existing data mount and `PGDATA` value unchanged. Do not remove or replace the volume.
3. Start it and inspect the PostgreSQL logs and existing databases **before** starting any new Immich installation or running SQL migrations. Check `SHOW server_version;`, `SHOW data_directory;`, `SHOW shared_preload_libraries;`, and `SELECT datname FROM pg_database;`. The preload value should include `pg_cron,vchord.so`.
4. If the cluster is not the expected one, stop the container and restore the previous image and mount settings. Do not initialize a new cluster in an empty directory.

**Command override:** If your Unraid template overrides the image's command, ensure that its `shared_preload_libraries` includes both `pg_cron` and `vchord.so`, plus any libraries you already preload.

## SplitPro and Immich on one PostgreSQL server

Keep SplitPro and Immich in **separate databases** with separate database users. `pg_cron` scheduling metadata can live in only one database per cluster; retain the `cron.database_name` that SplitPro uses, and do not drop or move its extension or jobs just to add Immich. Immich uses `pgvector` and VectorChord, not the `pg_cron` scheduling database.

For a new Immich database, set the ImageGenius Immich container's `DB_HOSTNAME`, `DB_USERNAME`, `DB_PASSWORD`, and `DB_DATABASE_NAME` to that database. Immich also needs Redis/Valkey and separate persistent photo/config storage. The image only installs PostgreSQL extension files; it does **not** create the `vchord` extension in an existing database or grant its app user permissions. If using a non-superuser Immich role, follow [Immich's pre-existing PostgreSQL instructions](https://docs.immich.app/administration/postgres-standalone/): make it the owner of its database and, as a DB administrator connected to the Immich database, run `CREATE EXTENSION vchord CASCADE;` and `CREATE EXTENSION earthdistance CASCADE;`. Immich notes that this advanced non-superuser setup can need manual intervention on upgrades and that its automatic backups currently require superuser access.

The ImageGenius example uses PostgreSQL 14 with VectorChord 0.4.3, while Immich's current standalone guidance accepts VectorChord `>=0.3,<2.0` and pgvector `>=0.7,<0.9`; this image uses VectorChord 1.1.1 and tests the pgvector version before publishing. If a future extension update changes binary files, updating an already-created extension and reindexing may require manual SQL per the Immich guide. Do not change to a different PostgreSQL **major** tag with this existing data directory: a major upgrade needs a planned migration/backup/restore.

**PostgreSQL 14 reached end of life on 12 November 2026.** This image keeps PG14 to preserve your current cluster without a major migration, but upstream security and bug-fix releases have ended. Plan a separate upgrade to a supported PostgreSQL major version; the image update alone cannot perform that safely.

Publishing currently supports `linux/amd64`. The GHCR package must be public for anonymous pulls. Check [Actions](https://github.com/Neverbolt/postgres-with-pg_cron/actions) and package visibility before pulling a newly published tag.
