#!/bin/bash
set -eu

if [ "${RUNNER_DEBUG:-}" = "1" ] ; then
  set -x
fi

mkdir -p "${INPUT_OUTPUT_DIR}"
OUTPUT_FILE_NAME="reviewdog-${INPUT_TOOL_NAME}"
if [[ "${INPUT_REPORTER}" == "sarif" ]]; then
  OUTPUT_FILE_NAME="${OUTPUT_FILE_NAME}.sarif"
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

cd "${RUNNER_TEMP}" || exit 1

if [ -z "${RUNNER_TOOL_CACHE:-}" ]; then
  RUNNER_TOOL_CACHE="$(mktemp -d)"
fi

# Normalize RUNNER_TOOL_CACHE to Unix-style path for Git Bash compatibility
TOOL_CACHE_PATH="$(cd "${RUNNER_TOOL_CACHE}" && pwd)"

# Get system architecture
ARCH=$(uname -m)
if [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
  CPU_ARCH="aarch64"
else
  CPU_ARCH="x86_64"
fi

OS_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')

case "${OS_NAME}" in
  linux) ;;
  darwin) ;;
  *)
    OS_NAME="windows"
    EXECUTABLE_EXT=".exe"
    ;;
esac

echo '::group::🐶 Installing shellcheck ... https://github.com/koalaman/shellcheck'
SHELLCHECK_PATH="${TOOL_CACHE_PATH}/shellcheck/${SHELLCHECK_VERSION}"
mkdir -p "${SHELLCHECK_PATH}/bin"

install_shellcheck() {
  local WINDOWS_TARGET=zip
  
  # Set targets based on OS and architecture
  if [[ "${OS_NAME}" == "linux" ]]; then
    local LINUX_TARGET="linux.${CPU_ARCH}.tar.xz"
    curl -sL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.${LINUX_TARGET}" | tar -xJf -
    cp "shellcheck-v$SHELLCHECK_VERSION/shellcheck" "${SHELLCHECK_PATH}/bin"
  elif [[ "${OS_NAME}" == "darwin" ]]; then
    local MACOS_TARGET="darwin.${CPU_ARCH}.tar.xz"
    curl -sL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.${MACOS_TARGET}" | tar -xJf -
    cp "shellcheck-v$SHELLCHECK_VERSION/shellcheck" "${SHELLCHECK_PATH}/bin"
  else
    curl -sL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.${WINDOWS_TARGET}" -o "shellcheck-v${SHELLCHECK_VERSION}.${WINDOWS_TARGET}" && unzip "shellcheck-v${SHELLCHECK_VERSION}.${WINDOWS_TARGET}" && rm "shellcheck-v${SHELLCHECK_VERSION}.${WINDOWS_TARGET}"
    cp "shellcheck.exe" "${SHELLCHECK_PATH}/bin"
  fi
}

if [ ! -f "${SHELLCHECK_PATH}/bin/shellcheck${EXECUTABLE_EXT:-}" ]; then
    install_shellcheck
else
    echo "shellcheck v${SHELLCHECK_VERSION} is already installed."
fi

export PATH="${SHELLCHECK_PATH}/bin:$PATH"
shellcheck --version
echo '::endgroup::'

echo '::group::🐶 Installing pyflakes ... https://github.com/PyCQA/pyflakes'
if ! command -v pipx &> /dev/null; then
  echo "pipx could not be found, pyfakes installation skipped."
else
  pipx install pyflakes
  pyflakes --version
fi
echo '::endgroup::'
  
echo '::group::🐶 Installing actionlint ... https://github.com/rhysd/actionlint'

install_actionlint() {
  ACTIONLINT_PATH="${TOOL_CACHE_PATH}/actionlint/${ACTIONLINT_VERSION}"
  mkdir -p "${ACTIONLINT_PATH}/bin"
  cd "${ACTIONLINT_PATH}/bin" || exit 1
  bash <(curl https://raw.githubusercontent.com/rhysd/actionlint/f8a7ad2624edffd2d432f5b4f40d79b92e48df6a/scripts/download-actionlint.bash) "${ACTIONLINT_VERSION}"
}

if [ ! -f "${TOOL_CACHE_PATH}/actionlint/${ACTIONLINT_VERSION}/bin/actionlint${EXECUTABLE_EXT:-}" ]; then
    install_actionlint
else
    echo "actionlint v${ACTIONLINT_VERSION} is already installed."
fi

export PATH="${ACTIONLINT_PATH}/bin:$PATH"
actionlint --version
echo '::endgroup::'

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
fi

echo '::group:: Running actionlint with reviewdog 🐶 ...'
# shellcheck disable=SC2086
actionlint -oneline ${INPUT_ACTIONLINT_FLAGS} | while read -r r; do
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
done \
    | reviewdog \
        -efm="%t:%f:%l:%c: %m" \
        -name="${INPUT_TOOL_NAME}" \
        -reporter="${INPUT_REPORTER}" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-level="${INPUT_FAIL_LEVEL}" \
        -level="${INPUT_LEVEL}" \
        ${INPUT_REVIEWDOG_FLAGS} \
    | tee "${INPUT_OUTPUT_DIR}/${OUTPUT_FILE_NAME}"

exit_code=${PIPESTATUS[2]}
echo '::endgroup::'
exit "$exit_code"
