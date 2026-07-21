#!/bin/sh

set -eu
if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

ACTIONLINT_VERSION=1.7.7

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  INSTALL_DIR=$(mktemp -d)
  echo "$INSTALL_DIR" >> "$GITHUB_PATH"
else
  INSTALL_DIR=/usr/local/bin/
fi

cd "$INSTALL_DIR"
export OSTYPE=linux-gnu
wget -O - -q https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash | sh -s -- "$ACTIONLINT_VERSION"
