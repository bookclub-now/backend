# BookClub

## Containerized Setup (you already have Elixir/MIX installed)

Copy the `rel.env.sample` file:
```
$ cp rel.env.sample rel.env
```

Edit the `rel.env` file with the proper environment values. Ask the maintainer about the missing values if you don't have those.

Start the Postgres container:
```
$ docker-compose up -d postgres
```

Build our Docker image:
```
$ docker-compose build app
```

Run migrations direct from the release:
```
$ docker-compose run --rm app app/bin/bookclub migrate
```

Run the application in foreground mode:
```
$ docker-compose up app
```

Or run the application in background mode:
```
$ docker-compose up -d app
```

## Containerized Setup (you prefer to run everything into containers)

Copy the `rel.env.sample` file:
```
$ cp rel.env.sample rel.env
```

Edit the `rel.env` file with the proper environment values. Ask the maintainer about the missing values if you don't have those.

Start BookClub container:
```
$ docker-compose up -d bookclub
```

Enter into container:
```
$ docker container exec -it bookclub sh
```

You may need to install make and node for alpine:
```
$ apk add build-base
$ apk add --update nodejs nodejs-npm
```

Install dependencies, give yes for (Hex), run tests and you are ready:
```
$ mix deps.get
$ npm i --prefix ./assets
$ MIX_ENV=test mix test
$ MIX_ENV=dev mix ecto.reset && mix phx.server
```

## Native Setup

**Requirements**
- Elixir 1.7

Start the Postgres container:
```
$ docker-compose up -d postgres
```

*Using a Docker PSQL helps a lot, but if you have a local PSQL server, then in this case you should edit your `.env` file with its credentials and create the database yourself (or by `mix ecto.create`).*

Install Hex and Rebar:
```
$ mix local.hex --force
```

```
$ mix local.rebar --force
```

Download dependencies:
```
$ mix deps.get
```

Compile everything:
```
$ mix compile
```

Copy our `.env.sample` file:
```
$ cp .env.sample .env
```

Edit the `.env` file with the proper environment values. Ask the maintainer about the missing values if you don't have those.

After editing, load our development environment variables file:
```
$ eval $(cat .env)
```

Run migrations:
```
$ mix ecto.migrate
```

Start the server:
```
$ mix phx.server
```

**Testing**
```
$ MIX_ENV=test mix test
```
