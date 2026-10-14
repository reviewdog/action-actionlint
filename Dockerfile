FROM python:3.15.0-alpine3.24@sha256:ff4d3c9b1a48f646eedd93182aaea385c7a5452f4c8a8cd7cef686babacf4928

RUN apk --no-cache add git curl bash

COPY scripts scripts

# install pyflakes
RUN ./scripts/install-pyflakes.sh

# install shellcheck
RUN ./scripts/install-shellcheck.sh

# install actionlint
RUN OSTYPE=linux-gnu ./scripts/install-actionlint.sh

# install reviewdog
RUN ./scripts/install-reviewdog.sh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
