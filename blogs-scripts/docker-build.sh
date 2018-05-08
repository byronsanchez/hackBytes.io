#!/bin/sh

sudo docker build -t byronsanchez/wintersmith-docker -f blogs-deploy/wintersmith-docker.Dockerfile .
sudo docker build -t byronsanchez/hackbytes.io -f blogs-deploy/hackbytes.io.Dockerfile .
sudo docker build -t byronsanchez/nitelite.io -f blogs-deploy/nitelite.io.Dockerfile .
