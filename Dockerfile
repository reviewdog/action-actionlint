FROM python:3.14.7-alpine3.24@sha256:6f945b4c17e0a1ee862ada29a91406bc86d58180ce7de902d8de1f30730e3760

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
