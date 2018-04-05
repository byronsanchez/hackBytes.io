#!/usr/bin/env bash

docker run --init -it --rm -p 8082:8080 -v ${pwd}/hackbytes.io-web:/home/wintersmith/hackbytes.io -m 300M --memory-swap 1G byronsanchez/hackbytes.io $args
