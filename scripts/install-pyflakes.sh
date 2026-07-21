#!/bin/sh
set -eu

if [ -n "${RUNNER_DEBUG:-}" ] ; then
  set -x
fi

cd "$(dirname "$0")"
python3 -m venv venv
. venv/bin/activate
python3 -m pip install --no-cache-dir --upgrade pip
python3 -m pip install --no-cache-dir -r ./requirements.txt
