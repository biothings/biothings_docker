FROM node:14 AS build
WORKDIR /build/src/github.com/biothings/biothings_studio
RUN git clone https://github.com/biothings/biothings_studio .
WORKDIR /build/src/github.com/biothings/biothings_studio/webapp
RUN npm install && npm run build --legacy-peer-deps

FROM nginx:mainline
COPY --from=build --chown=www-data:www-data /build/src/github.com/biothings/biothings_studio/webapp/dist /srv/webapp
COPY webapp.conf /etc/nginx/conf.d/default.conf