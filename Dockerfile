FROM alpine:3.11

RUN apk update && apk add ca-certificates git curl jq && rm -rf /var/cache/apk/* && update-ca-certificates

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]