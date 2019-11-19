FROM node:10-alpine as env

RUN apk add --update --repository http://dl-3.alpinelinux.org/alpine/edge/main --update-cache fftw-dev && \
    apk add --update --repository http://dl-3.alpinelinux.org/alpine/edge/community --update-cache \
	vips-dev vips-tools gcc g++ make libc6-compat && \
    apk add git && \
    apk add python && \
    rm -rf /var/cache/apk/*

RUN npm config set unsafe-perm true
RUN npm install --global gatsby --no-optional gatsby@1.9

EXPOSE 80

########################################################################################################################
FROM env as base
RUN mkdir -p /site
WORKDIR /site
VOLUME /site

########################################################################################################################
FROM base as local
RUN apk add bash
RUN echo 'alias ll="ls -lahG"' >> ~/.bashrc
