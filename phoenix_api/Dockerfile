
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

RUN apk add --no-cache bash libstdc++ openssl ncurses postgresql-client

RUN addgroup -g 1000 app && \
    adduser -D -s /bin/sh -u 1000 -G app app

WORKDIR /app

COPY --from=builder --chown=app:app /app/_build/prod/rel/phoenix_api ./

# Copy startup script
COPY --chown=app:app start.sh /app/start.sh
RUN chmod +x /app/start.sh

USER app

EXPOSE 4000

ENV MIX_ENV=prod
ENV PORT=4000
ENV PHX_HOST=localhost
ENV DB_HOST=db
ENV DB_PORT=5432
ENV DB_USER=postgres

CMD ["/app/start.sh"] 
