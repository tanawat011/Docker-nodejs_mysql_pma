# Docker: Node.js + MySQL (MariaDB) + phpMyAdmin

A Docker Compose setup for developing a Node.js app against MariaDB, with
two web tools to look at the database: phpMyAdmin and Adminer. The
`Dockerfile` explains each instruction in Thai.

| Service | Image | On this machine |
|---|---|---|
| `db` | `mariadb:12.3.3` | inside the compose network only (`db:3306`) |
| `adminer` | `adminer:6.3.1` | http://localhost:2101 |
| `pma` | `phpmyadmin:5.2.3-apache` | http://localhost:2102 |
| `node_express` | built from `Dockerfile` | http://localhost:2103 (`/`, `/db`, `/health`) |

Originally written in 2018 while learning Docker and Docker Compose;
refreshed in Nov 2026: current, pinned images (Node 6 and MariaDB 10.1 were
long out of support), a small app so the image builds, passwords out of the
compose file, healthchecks, ports on 127.0.0.1 only, tests and CI.

## Quick start

Needs Docker with Compose v2.

```sh
git clone https://github.com/tanawat011/Docker-nodejs_mysql_pma.git
cd Docker-nodejs_mysql_pma
cp .env.example .env              # dev-only placeholder passwords; change them if you like
docker compose up -d --build --wait

curl localhost:2103/db            # the app reads the database
open http://localhost:2102        # phpMyAdmin: sign in as DB_USER / DB_PASSWORD from .env
```

- `docker compose watch` copies an edited `server.js` into the container
  and restarts it.
- `docker compose down` stops everything; add `-v` to delete the database.

The passwords in `.env` are for this local setup only. Every port is bound
to 127.0.0.1, so nothing is reachable from other machines.

## Tests

```sh
npm ci && npm test     # the app's routes, with a stand-in database
```

CI also starts the whole stack and calls every service.
