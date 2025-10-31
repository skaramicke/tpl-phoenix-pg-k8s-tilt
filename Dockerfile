# ---- Builder Stage ----
FROM elixir:1.18 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y nodejs npm build-essential

# Set environment variables
ENV MIX_ENV=prod

# Set app directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy app files
COPY mix.exs mix.lock ./
COPY config config
COPY lib lib
COPY assets assets
COPY priv priv

# Install dependencies and compile
RUN mix deps.get --only prod && \
    mix deps.compile && \
    cd assets && npm install && npm run deploy && \
    cd .. && mix phx.digest && \
    mix release

# ---- Release Image ----
FROM debian:bullseye-slim AS runtime

RUN apt-get update && apt-get install -y openssl

WORKDIR /app

# Copy built release from builder
COPY --from=builder /app/_build/prod/rel/YOUR_APP_NAME ./

ENV HOME=/app

USER nobody

EXPOSE 4000

CMD ["bin/YOUR_APP_NAME", "start"]
