#!/bin/sh

sudo docker run --init -it --rm -p 8084:8080 \
  -v `pwd`/blogs-libs:/home/wintersmith/blogs-libs \
  -v `pwd`/blogs-web/globals:/home/wintersmith/globals \
  -v `pwd`/blogs-web/nitelite.io-web:/home/wintersmith/nitelite.io \
  -m 300M --memory-swap 1G byronsanchez/nitelite.io \
  $@
