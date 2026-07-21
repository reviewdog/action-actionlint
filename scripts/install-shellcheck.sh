#!/bin/bash

set -euo pipefail
if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

SHELLCHECK_VERSION=0.11.0
OS_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
if [ "${ARCH}" = "arm64" ] || [ "${ARCH}" = "aarch64" ]; then
  CPU_ARCH="aarch64"
else
  CPU_ARCH="x86_64"
fi

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  INSTALL_DIR=$(mktemp -d)
  echo "$INSTALL_DIR" >> "$GITHUB_PATH"
else
  INSTALL_DIR=/usr/local/bin/
fi

case "${OS_NAME}" in
  linux)
    curl -sSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.${CPU_ARCH}.tar.xz" | tar -xJf - --strip-components=1 -C "${INSTALL_DIR}" "shellcheck-v${SHELLCHECK_VERSION}/shellcheck"
    ;;
  darwin)
    curl -sSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.darwin.${CPU_ARCH}.tar.xz" | tar -xJf - --strip-components=1 -C "${INSTALL_DIR}" "shellcheck-v${SHELLCHECK_VERSION}/shellcheck"
    ;;
  *) # windows
    curl -sSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.zip" -o shellcheck.zip
    unzip shellcheck.zip -d "${INSTALL_DIR}"
    rm shellcheck.zip
    ;;
esac
