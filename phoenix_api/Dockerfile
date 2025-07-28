
FROM elixir:1.18.2-alpine AS builder

WORKDIR /app

RUN apk add --no-cache build-base git nodejs npm

COPY mix.exs mix.lock ./

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only=dev

COPY . .

RUN MIX_ENV=prod mix deps.compile && \
    MIX_ENV=prod mix compile

RUN MIX_ENV=prod mix release --overwrite

FROM alpine:latest AS app

RUN apk add --no-cache bash libstdc++ openssl ncurses

RUN addgroup -g 1000 app && \
    adduser -D -s /bin/sh -u 1000 -G app app

WORKDIR /app

COPY --from=builder --chown=app:app /app/_build/prod/rel/phoenix_api ./

USER app

EXPOSE 4000

ENV MIX_ENV=prod
ENV PORT=4000
ENV PHX_HOST=localhost

CMD ["bin/phoenix_api", "start"] 
