FROM node:10-alpine AS base
RUN apk add --no-cache -X 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' pandoc

FROM base AS build
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm ci --ignore-scripts
COPY entrypoint.sh .
RUN sed -i '3 s:root=.*:root=/app:' entrypoint.sh
COPY build.js .
COPY template.htm .
RUN rm package.json package-lock.json

FROM base
COPY --from=build /app /app
ENTRYPOINT [ "/app/entrypoint.sh" ]
