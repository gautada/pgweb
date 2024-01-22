# pgweb

## Abstract

[pgweb](http://sosedoff.github.io/pgweb/) makes PostgreSQL administration more accessible and to make the overall usage easier. **pgweb** is a web-based database browser for PostgreSQL, written in Go with zero-dependency binaries. **pgweb** was created as an attempt to build very simple and portable application to work with local or remote PostgreSQL databases. This project is open-sourced and maintained in a [github repository](https://github.com/sosedoff/pgweb).

## Development

## Database URL

The database url used for development is provided through a a system environment variable (COMPOSE_PGWEB_DATABASE_URL). The format of the URL is the typical [postgres URL](https://www.prisma.io/dataguide/postgresql/short-guides/connection-uris) (postgres://pgweb@{HOST.DOMAIN.TLD}:5432/postgres?connect_timeout=30&sslmode=disable)

```
postgres[ql]://[username[:password]@][host[:port],]/database[?parameter_list]

\_____________/\____________________/\____________/\_______/\_______________/
	 |                   |                  |          |            |
	 |- schema           |- userspec        |          |            |- parameter list
											|          |
											|          |- database name
											|
											|- hostspec
```

- **pgsql**: username - this is the default username that should be setup in postgres
- **HOST.DOMAIN.TLD**: host - this is the fully-qualified domain name of the postgres server
- **postgres**: database - the default database to connect into
- **connect_timeout=30&sslmode=disable**: parameter_list - the connection parameters to use.

### Variables

**compose.yml** needs to have some variables set, to-do document.

