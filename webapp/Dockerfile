FROM node:14 AS build

ARG STUDIO_GIT=https://github.com/biothings/biothings_studio.git
ARG GIT_TAG=master

WORKDIR /build/src/github.com/biothings/biothings_studio
RUN git clone ${STUDIO_GIT} .
RUN git checkout ${GIT_TAG}
WORKDIR /build/src/github.com/biothings/biothings_studio/webapp
RUN npm install && npm run build --legacy-peer-deps

FROM nginx:mainline-alpine
EXPOSE 80/tcp
RUN mkdir -p /data/nginx
RUN chown -R nginx:nginx /data/nginx
COPY --from=build --chown=root:www-data /build/src/github.com/biothings/biothings_studio/webapp/dist /srv/www/webapp
COPY webapp.conf /etc/nginx/conf.d/default.conf
VOLUME [ "/data" ]
