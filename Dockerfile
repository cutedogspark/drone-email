FROM alpine:3.6

RUN apk update && \
  apk add \
    ca-certificates \
    mailcap && \
  rm -rf /var/cache/apk/*

ADD bin/linux/amd64/drone-email /bin/
ENTRYPOINT ["/bin/drone-email"]
