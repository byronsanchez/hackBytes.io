
FROM node:9.9-alpine
LABEL maintainer "Byron Sanchez <byron@hackbytes.io>"

# --
# EnvVars
# Image
# --
ENV WINTERSMITH_VAR_DIR=/var/wintersmith
ENV WINTERSMITH_DATA_DIR=/srv/wintersmith

# --
# EnvVars
# System
# --
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV TZ=America/New_York
#ENV PATH="$PATH"
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US

# --
# Packages
# Dev
# --
RUN apk --no-cache add \
  zlib-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  readline-dev \
  libffi-dev \
  yaml-dev \
  zlib-dev \
  libffi-dev \
  cmake

# --
# Packages
# Main
# --

# Git is needed to pull in some front-end dependencies
RUN apk --no-cache add \
  linux-headers \
  openjdk8-jre \
  less \
  zlib \
  libxml2 \
  readline \
  libxslt \
  libffi \
  git \
  nodejs \
  tzdata \
  shadow \
  bash \
  su-exec \
  nodejs-npm \
  libressl \
  yarn

# --
# node_modules
# Update
# --
RUN npm update -g

# --
# node_modules
# Main
# --
RUN npm install -g wintersmith

# --
RUN addgroup -Sg 1001 wintersmith
RUN adduser  -Su 1001 -G \
  wintersmith wintersmith

# --
# Remove development packages.
# node_modules are unsupported.
# --

RUN apk --no-cache del \
  linux-headers \
  openjdk8-jre \
  zlib-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  readline-dev \
  libffi-dev \
  ruby-dev \
  yaml-dev \
  zlib-dev \
  libffi-dev \
  cmake

# --
RUN mkdir -p $WINTERSMITH_VAR_DIR
RUN mkdir -p $WINTERSMITH_DATA_DIR
RUN chown -R wintersmith:wintersmith $WINTERSMITH_DATA_DIR
RUN chown -R wintersmith:wintersmith $WINTERSMITH_VAR_DIR

# --
CMD ["wintersmith", "--help"]
WORKDIR /srv/wintersmith
VOLUME  /srv/wintersmith
EXPOSE 35729
EXPOSE 8080
