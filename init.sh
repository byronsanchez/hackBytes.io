#!/usr/bin/env sh

# ruby dependency validation
command -v gem >/dev/null 2>&1 || {
  printf >&2 "Please install Ruby\n";
  exit 1;
}

command -v bundle >/dev/null 2>&1 || {
  printf >&2 "Installing bundler...\n";
  gem install bundler
  gem update rdoc
}

# Initialization to setup a buildable application
bundle install --local --path vendor/bundle

