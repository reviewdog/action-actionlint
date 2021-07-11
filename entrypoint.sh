#!/bin/sh

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

actionlint -oneline | reviewdog -efm="%f:%l:%c: %m"
