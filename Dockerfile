FROM alpine:3.11.6 AS base
RUN apk add --no-cache -X 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' pandoc nodejs

FROM base AS build
RUN apk add --no-cache npm
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm ci --ignore-scripts
COPY entrypoint.sh .
RUN sed -i '3 s:root=.*:root=/app:' entrypoint.sh
COPY build.js .
COPY template.htm .

FROM base
COPY --from=build /app /app
ENTRYPOINT [ "/app/entrypoint.sh" ]
