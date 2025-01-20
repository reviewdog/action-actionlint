FROM python:3.12-alpine

RUN pip3 install --upgrade pip && \
  pip3 install pyflakes && \
  rm -r /root/.cache

ENV SHELLCHEK_VERSION=v0.10.0
RUN set -x; \
  arch="$(uname -m)"; \
  echo "arch is $arch"; \
  if [ "${arch}" = 'armv7l' ]; then \
  arch='armv6hf'; \
  fi; \
  url_base='https://github.com/koalaman/shellcheck/releases/download/'; \
  tar_file="${SHELLCHEK_VERSION}/shellcheck-${SHELLCHEK_VERSION}.linux.${arch}.tar.xz"; \
  wget "${url_base}${tar_file}" -O - | tar xJf -; \
  mv "shellcheck-${SHELLCHEK_VERSION}/shellcheck" /bin/; \
  rm -rf "shellcheck-${SHELLCHEK_VERSION}"; \
  ls -laF /bin/shellcheck

RUN apk --update add git curl && \
  rm -rf /var/lib/apt/lists/* && \
  rm /var/cache/apk/*

# install reviewdog
ENV REVIEWDOG_VERSION=v0.20.3
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

# install actionlint
ENV ACTIONLINT_VERSION=1.7.7
ENV OSTYPE=linux-gnu
RUN cd /usr/local/bin/ && wget -O - -q https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash | sh -s -- ${ACTIONLINT_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
