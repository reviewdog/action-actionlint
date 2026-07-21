#!/bin/sh
set -eu

if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

cd "$(dirname "$0")"

OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
if [ "${OS_NAME}" = "darwin" ]; then
  pipx install "$(cat ./requirements.txt)"
else
  python3 -m pip install --no-cache-dir --upgrade pip
  python3 -m pip install --no-cache-dir -r ./requirements.txt
fi
