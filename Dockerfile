# ---------------------------------------------------------
# Build Release
# ---------------------------------------------------------
FROM elixir:1.7-alpine as build

WORKDIR /app

RUN apk add -U --no-cache \
    git build-base wget curl inotify-tools nodejs nodejs-npm make gcc libc-dev && \
    npm install npm -g --no-progress

ENV MIX_ENV=prod \
    PATH=./node_modules/.bin:$PATH

COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force

RUN mix deps.get && \
    mix deps.compile

RUN cd assets && \
    npm install && \
    npm run deploy && \
    cd .. && \
    mix phx.digest

RUN mix compile && \
    mix release

RUN mkdir /export && \
    export REL=`ls -d _build/prod/rel/bookclub/releases/*/` && \
    tar -xzf "$REL/bookclub.tar.gz" -C /export

# ---------------------------------------------------------
# Run Release
# ---------------------------------------------------------
FROM erlang:21-alpine

ARG PUID=1000
ARG PGID=1000
ARG HOME="/app"

RUN apk add -U --no-cache bash ncurses-libs openssl tzdata

RUN addgroup -g ${PGID} bookclub && \
    adduser -S -h ${HOME} -G bookclub -u ${PUID} bookclub

COPY --from=build --chown=bookclub:bookclub /export /app/.

EXPOSE 4000

USER bookclub

ENV MIX_ENV=prod

CMD /app/bin/bookclub foreground

