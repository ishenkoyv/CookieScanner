# build stage
FROM golang:stretch AS builder
WORKDIR /go/src/github.com/CovenantSQL/CookieScanner
COPY . .
RUN CGO_ENABLED=1 GOOS=linux go install -ldflags '-linkmode external -extldflags -static'

# stage runner
FROM zenika/alpine-chrome:latest
WORKDIR /app
USER root
RUN echo "@main http://dl-cdn.alpinelinux.org/alpine/v3.11/main" >> /etc/apk/repositories \
    && echo "@main http://dl-cdn.alpinelinux.org/alpine/v3.11/community" >> /etc/apk/repositories
RUN apk add --no-cache mesa-egl@main mesa-gles@main ca-certificates@main tini@main
USER chrome
COPY --from=builder /go/bin/CookieScanner /app/
ENTRYPOINT ["/sbin/tini", "--", "/app/CookieScanner", "server"]
CMD []
