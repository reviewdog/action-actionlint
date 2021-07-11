FROM koalaman/shellcheck-alpine:latest

RUN apk --update add git curl && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

# install reviewdog
ENV REVIEWDOG_VERSION=v0.12.0
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

# install actionlint
ENV ACTIONLINT_VERSION=1.4.0
ENV OSTYPE=linux-gnu
RUN cd /usr/local/bin/ && wget -O - -q https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash | sh -s -- ${ACTIONLINT_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
