FROM alpine:3.14

ENV BUMP_VERSION=v1.1.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk --no-cache add git jq grep curl
RUN wget -O - -q https://raw.githubusercontent.com/haya14busa/bump/master/install.sh| sh -s -- -b /usr/local/bin/ ${BUMP_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
