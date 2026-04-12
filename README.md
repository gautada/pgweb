# pgweb

## Abstract

[pgweb](http://sosedoff.github.io/pgweb/) makes PostgreSQL administration more accessible
and to make the overall usage easier. **pgweb** is a web-based database browser for
PostgreSQL, written in Go with zero-dependency binaries. **pgweb** was created
as an attempt to build very simple and portable application to work with local
or remote PostgreSQL databases. This project is open-sourced and maintained
a [GitHub repository](https://github.com/sosedoff/pgweb).

## Development

## Database URL

The database URL used for development is provided through a a system
environment variable(COMPOSE_PGWEB_DATABASE_URL). The format of the URL is
the typical [postgres URL](https://www.prisma.io/dataguide/postgresql/short-guides/connection-uris)

postgres://pgweb@{HOST.DOMAIN.TLD}:5432/postgres?connect_timeout=30&sslmode=disable

- **pgsql**: username - this is the default username that should be setup
in postgres
- **HOST.DOMAIN.TLD**: host - this is the fully-qualified domain name of the
postgres server
- **postgres**: database - the default database to connect into
- **connect_timeout=30&sslmode=disable**: parameter_list - the connection
parameters to use.

### Variables

**compose.yml** needs to have some variables set, to-do document.

## Notes

- 2024-02-26: FF to fix build error.

## Bookmarks and Saved Queries

pgweb supports saved database connection bookmarks via `.toml` files mounted
at `/mnt/volumes/configmaps/bookmarks/`. The service script automatically
enables bookmarks when this directory exists.

### Bookmark File Format

Create one `.toml` file per bookmark in `/mnt/volumes/configmaps/bookmarks/`:

```toml
# /mnt/volumes/configmaps/bookmarks/mydb.toml
[bookmark]
url      = "postgres://user:password@host:5432/dbname"
# Optional: pre-load a query when this bookmark is selected
# query = "SELECT * FROM users LIMIT 10;"
```

Or using individual fields:

```toml
[bookmark]
host     = "postgres-host"
port     = 5432
user     = "pgweb"
password = "secret"
database = "mydb"
sslmode  = "disable"
```

### Kubernetes ConfigMap Example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: pgweb-bookmarks
data:
  production.toml: |
    [bookmark]
    host     = "postgres"
    port     = 5432
    user     = "pgweb"
    database = "app"
    sslmode  = "require"
```

Mount at `/mnt/volumes/configmaps/bookmarks` in your pod spec.

### Saved Queries

pgweb does not provide server-side persistent query storage. The
`query` field in a bookmark `.toml` file pre-populates the query
editor when the bookmark connection is opened, providing a
workflow for commonly used queries. Query history is stored in the
browser's local storage.
