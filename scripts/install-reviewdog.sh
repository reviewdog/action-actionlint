#!/bin/bash

set -euo pipefail
if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

REVIEWDOG_VERSION=0.20.3

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  INSTALL_DIR=$(mktemp -d)
  echo "$INSTALL_DIR" >> "$GITHUB_PATH"
else
  INSTALL_DIR=/usr/local/bin/
fi

curl -sSL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "$INSTALL_DIR" "v$REVIEWDOG_VERSION"
