FROM python:3.15.2-alpine3.24@sha256:0f9552bb28711333da16915ec146f5e6bb44a7fdac9ced15dc17c2e0206346dd

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
