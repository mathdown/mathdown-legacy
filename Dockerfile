FROM alpine:3.10 AS alpine

FROM alpine AS base
RUN apk add --no-cache nodejs && apk add --no-cache -X 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' pandoc

FROM alpine AS git
RUN apk add --no-cache git
COPY .git .git
RUN mkdir .git/objects
RUN git rev-parse HEAD >HEAD

FROM base AS build
RUN apk add --no-cache npm
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm ci --ignore-scripts
COPY entrypoint.sh .
COPY --from=git HEAD .
RUN sed -i "3 s:root=.*:root=/app:" entrypoint.sh
RUN sed -i "4 s:ref=.*:ref=$(cat HEAD):" entrypoint.sh
COPY build.js .
COPY template.htm .
RUN rm HEAD package.json package-lock.json

FROM base
COPY --from=build /app /app
ENTRYPOINT [ "/app/entrypoint.sh" ]
