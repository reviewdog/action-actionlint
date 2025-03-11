FROM python:3.13-alpine

RUN pip3 install --upgrade pip && \
  pip3 install pyflakes && \
  rm -r /root/.cache

# Copy versions file
COPY .versions /.versions

RUN source /.versions \
 && set -x \
 && arch="$(uname -m)" \
 && echo "Detected architecture: $arch" \
 && if [ "${arch}" = 'armv7l' ]; then arch='armv6hf'; fi \
 && url_base='https://github.com/koalaman/shellcheck/releases/download/' \
 && tar_file="$SHELLCHECK_VERSION/shellcheck-$SHELLCHECK_VERSION.linux.${arch}.tar.xz" \
 && wget "${url_base}${tar_file}" -O - \
  | tar -xvJf - --strip-components=1 -C /bin "shellcheck-$SHELLCHECK_VERSION/shellcheck" \
 && ls -laF /bin/shellcheck

RUN apk --no-cache add git curl

# install reviewdog
RUN source /.versions \
 && wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ $REVIEWDOG_VERSION

# install actionlint
ENV OSTYPE=linux-gnu
RUN source /.versions \
 && cd /usr/local/bin/ \
 && wget -O - -q https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash | sh -s -- $ACTIONLINT_VERSION

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
