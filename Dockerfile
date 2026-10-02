FROM python:3.14.8-alpine3.24@sha256:8acac70227ce3b34da9453120c375cc5b66cd0b062d4dc6bc74286f81a3819e1

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
