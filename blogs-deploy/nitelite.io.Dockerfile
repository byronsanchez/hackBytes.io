
FROM byronsanchez/wintersmith-docker
LABEL maintainer "Byron Sanchez <byron@hackbytes.io>"

RUN apk --no-cache add \
  sqlite

RUN npm install -g webpack \
  coffeescript \
  postcss-cli

WORKDIR /home/wintersmith

# Global Package directory
RUN mkdir /home/wintersmith/blogs-universal
# App Package directory
RUN mkdir /home/wintersmith/local-packages
# App directory
RUN mkdir /home/wintersmith/blogs-nitelite

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
COPY ./blogs-universal/package.json /home/wintersmith/blogs-universal
WORKDIR /home/wintersmith/blogs-universal
RUN npm install --prefix /home/wintersmith/blogs-universal
ENV NODE_PATH /home/wintersmith/blogs-universal/node_modules:$NODE_PATH
ENV PATH /home/wintersmith/blogs-universal/node_modules/.bin:$PATH

# Copy this blog's specific packages
#
# Doesn't look like local-packages is actually doing anything, since all
# packages are defined in blogs-universal. Validate this and fix if necessary.
#
# It might do something if dependencies merge? but the docker tree structure
# isn't even with a parent directory like that.
#
# UPDATE: Turns out this really doesn't matter, there are no packages to install
# and it'll get bind mounted in development. The globals is what matters, it
# won't be bind mounted over in order to prevent dev node_module overrides.
COPY ./blogs-nitelite/package.json /home/wintersmith/local-packages
WORKDIR /home/wintersmith/local-packages
RUN npm install --prefix /home/wintersmith/local-packages
ENV NODE_PATH /home/wintersmith/local-packages/node_modules:$NODE_PATH
ENV PATH /home/wintersmith/local-packages/node_modules/.bin:$PATH

# Copy the global source files as the base, then overlay project specific divergences on top
COPY ./blogs-universal/ /home/wintersmith/blogs-universal
COPY ./blogs-nitelite/ /home/wintersmith/blogs-nitelite

WORKDIR /home/wintersmith/blogs-nitelite/templates

# Add symlinks to global templates
#
# NOTE: Ideally, this should work by the COPY command earlier, but it looks like
# on earlier docker versions (aka ~17.09, which is what the CI build host uses)
# does not support COPYing symlinks properly. So we're adding the symlink
# creation to this Dockerfile itself. In the future, test this out again on the
# build host until we can just COPY the symlinks with the earlier command
RUN rm globals
RUN ln -s ../../blogs-universal/src/templates/ globals

WORKDIR /home/wintersmith/blogs-nitelite

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
# VOLUME /var/lib/nitelite/blogs-nitelite/
