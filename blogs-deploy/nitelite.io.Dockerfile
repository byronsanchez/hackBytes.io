
FROM byronsanchez/wintersmith-docker
LABEL maintainer "Byron Sanchez <byron@hackbytes.io>"

RUN apk --no-cache add \
  sqlite

RUN npm install -g webpack \
  live-server \
  coffeescript \
  grunt-cli \
  postcss-cli

WORKDIR /home/wintersmith

# Global Package directory
RUN mkdir /home/wintersmith/global-packages
# App Package directory
RUN mkdir /home/wintersmith/local-packages
# App directory
RUN mkdir /home/wintersmith/nitelite.io

# can be used with USER to install global packages to a user directory
#RUN echo "prefix = /home/wintersmith/packages" > ~/.npmrc
# tell node where to resolve modules in require() statements

# Copy third-party dependencies
COPY ./blogs-libs/ /home/wintersmith/blogs-libs
WORKDIR /home/wintersmith/blogs-libs/wintersmith
# need to bootstrap wintersmith before it can be properly loaded as a dependency
# the blogs' package.json will expect compiled js as opposed to the source coffeescript
RUN npm install
RUN npm run prepublishOnly
WORKDIR /home/wintersmith

# Copy global packages shared across blogs
COPY ./blogs-web/package.json /home/wintersmith/global-packages
WORKDIR /home/wintersmith/global-packages
RUN npm install --prefix /home/wintersmith/global-packages
ENV NODE_PATH /home/wintersmith/global-packages/node_modules:$NODE_PATH
ENV PATH /home/wintersmith/global-packages/node_modules/.bin:$PATH

# Copy this blog's specific packages
COPY ./blogs-web/nitelite.io-web/package.json /home/wintersmith/local-packages
WORKDIR /home/wintersmith/local-packages
RUN npm install --prefix /home/wintersmith/local-packages
ENV NODE_PATH /home/wintersmith/local-packages/node_modules:$NODE_PATH
ENV PATH /home/wintersmith/local-packages/node_modules/.bin:$PATH

# Copy the global source files as the base, then overlay project specific divergences on top
COPY ./blogs-web/globals/ /home/wintersmith/nitelite.io
COPY ./blogs-web/nitelite.io-web/ /home/wintersmith/nitelite.io

WORKDIR /home/wintersmith/nitelite.io

#USER wintersmith

CMD ["npm", "run", "start-watch"]

# TODO: PHP (or replace it so I don't have to maintain it)
# - PHP7
# - PECL YAML

#RUN apk add php7 php7-fpm php7-opcache
#RUN apk add --no-cache --virtual .build-deps \
#    g++ make autoconf yaml-dev
#RUN pecl channel-update pecl.php.net
#RUN pecl install yaml-2.0.0 && docker-php-ext-enable yaml
#RUN apk del --purge .build-deps

# PHP Modules
#RUN apk add php7-gd php7-mysqli php7-zlib php7-curl

#CMD["/start"]
#/etc/init.d/php-fpm start;
#exec nginx

# TODO: other (execs, etc.)
# /var/lib/nitelite/webserver as a persistent data store
# VOLUME /var/lib/nitelite/nitelite.io/
