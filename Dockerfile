FROM elixir:1.11-alpine

# Create app directory and copy the project into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install packages
RUN apk add --no-cache --virtual .build-deps bash git less build-base inotify-tools \
  postgresql-dev postgresql-client openssh-client openssh-keygen ncurses procps && \
  apk add --update tzdata

# Install mix packages
RUN mix local.hex --force && mix local.rebar --force

RUN mix deps.get && mix deps.compile && mix compile

EXPOSE 4000
