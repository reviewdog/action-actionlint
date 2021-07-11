#!/bin/sh

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

actionlint -oneline ${INPUT_ACTIONLINT_FLAGS} \
    | reviewdog \
        -efm="%f:%l:%c: %m" \
        -name="actionlint" \
        -reporter="${INPUT_REPORTER}" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        -level="${INPUT_LEVEL}" \
        ${INPUT_REVIEWDOG_FLAGS}
