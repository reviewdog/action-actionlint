FROM python:3.15.2-alpine3.24@sha256:a0f2e268f2ce8f3709611a90054ec6a8ae31f6251f5896b8648b9bb99835e30a

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
