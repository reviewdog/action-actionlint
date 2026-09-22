#!/bin/sh

set -eu

if [ "${RUNNER_DEBUG:-}" = "1" ] ; then
  set -x
fi

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

# show versions of tools
echo "::group:: pyflakes version"
pyflakes --version
echo "::endgroup::"

echo "::group:: shellcheck version"
shellcheck --version
echo "::endgroup::"

echo "::group:: actionlint version"
actionlint --version
echo "::endgroup::"

echo "::group:: reviewdog version"
reviewdog --version
echo "::endgroup::"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

actionlint_out="$(mktemp)"
trap 'rm -f "${actionlint_out}"' EXIT

set +e
# Re-split INPUT_ACTIONLINT_FLAGS following shell quoting rules so that
# flag values containing spaces (e.g. -ignore="foo bar") survive intact.
eval "set -- ${INPUT_ACTIONLINT_FLAGS}"
actionlint -oneline "$@" > "${actionlint_out}"
actionlint_exit=$?
set -e

# actionlint exit codes: 0=no problem, 1=problems found, 2=invalid command
# line option, 3=fatal error while checking. 2 and 3 are operational
# failures of actionlint itself and must not be swallowed by reviewdog.
if [ "${actionlint_exit}" -ge 2 ]; then
  cat "${actionlint_out}"
  exit "${actionlint_exit}"
fi

# Re-split INPUT_REVIEWDOG_FLAGS following shell quoting rules so that flag
# values containing spaces (e.g. -diff="git diff main") survive intact.
eval "set -- ${INPUT_REVIEWDOG_FLAGS}"

while read -r r; do
  shellcheck_output=" shellcheck reported issue in this script: "
  severity=e

  # Parse the severity if the output is from shellcheck
  if echo "${r}" | grep "${shellcheck_output}"; then
    s="$(echo "${r}" | sed -e "s/^.*${shellcheck_output}[^:]*:\([^:]\).*$/\1/g")"
    if [ "${s}" = 'e' ] || [ "${s}" = 'w' ] || [ "${s}" = 'i' ] || [ "${s}" = 'n' ]; then
      severity="${s}"
    fi
  fi

  echo "${severity}:${r}"
done < "${actionlint_out}" \
    | reviewdog \
        -efm="%t:%f:%l:%c: %m" \
        -name="${INPUT_TOOL_NAME}" \
        -reporter="${INPUT_REPORTER}" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-level="${INPUT_FAIL_LEVEL}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        -level="${INPUT_LEVEL}" \
        "$@"
exit_code=$?

exit "${exit_code}"
