ARG MIX_ENV="prod"

## Build Phase
FROM hexpm/elixir:1.14.4-erlang-26.0-alpine-3.17.3 as build

RUN apk add --no-cache build-base git python3 curl nodejs npm

WORKDIR /app

ARG MIX_ENV
ARG REVISION

ENV MIX_ENV=${MIX_ENV}
ENV APP_REVISION=${REVISION}

RUN printenv

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock .formatter.exs ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config
COPY config/config.exs config/$MIX_ENV.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets
RUN cd assets/ && npm install
RUN mix assets.deploy

RUN mix compile

COPY config/runtime.exs config/

RUN mix release

## Run-Phase
FROM alpine:3.17.3 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs

ARG MIX_ENV
ARG REVISION

ENV APP_REVISION=${REVISION}

RUN printenv

WORKDIR "/home/elixir/app"

RUN \
  addgroup \
   -g 1000 \
   -S "elixir" \
  && adduser \
   -s /bin/sh \
   -u 1000 \
   -G "elixir" \
   -h "/home/elixir" \
   -D "elixir" \
  && su "elixir"

USER "elixir"

COPY --from=build --chown="elixir":"elixir" /app/_build/"${MIX_ENV}"/rel/heimdall ./

ENTRYPOINT ["bin/heimdall"]

# Usage:
#  * build: sudo docker image build -t elixir/heimdall .
#  * shell: sudo docker container run --rm -it --entrypoint "" -p 127.0.0.1:4000:4000 elixir/heimdall sh
#  * run:   sudo docker container run --rm -it -p 127.0.0.1:4000:4000 --name heimdall elixir/heimdall
#  * exec:  sudo docker container exec -it heimdall sh
#  * logs:  sudo docker container logs --follow --tail 100 heimdall

CMD ["start"]

ENV ECTO_IPV6 false
ENV ERL_AFLAGS "-proto_dist inet6_tcp"
