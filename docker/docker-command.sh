#!/bin/sh
while ! nc -z db 5432;
do
  echo "=== Waiting for Postgres... ===";
  sleep 3;
done;
echo "=== Connected to Postgres! ===";
echo "=== Starting application... ===";

export MIX_ENV=dev
mix deps.get
mix ecto.migrate
mix phx.server
