FROM ruby:2.7-slim-buster

WORKDIR /app

RUN apt-get update && apt-get install -y \
      build-essential \
      git \
      && rm -rf /var/lib/apt/lists/*

COPY . .

RUN bundle install

ENTRYPOINT ["/bin/bash", "-lc"]
