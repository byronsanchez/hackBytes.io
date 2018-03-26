#!/usr/bin/env sh

# npm dependency validation
command -v npm >/dev/null 2>&1 || {
  printf >&2 "Please install Node.js\n";
  exit 1;
}

# ruby dependency validation
command -v gem >/dev/null 2>&1 || {
  printf >&2 "Please install Ruby\n";
  exit 2;
}

# ruby dependency validation
command -v bower >/dev/null 2>&1 || {
  printf >&2 "Please install Bower\n";
  exit 2;
}

command -v bundle >/dev/null 2>&1 || {
  printf >&2 "Installing bundler...\n";
  gem install bundler
  gem update rdoc
}

bower install
bundle install

