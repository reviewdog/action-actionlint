#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

# Setup these env variables. It can exit 0 for unknown label.
# - LABELS
# - PR_NUMBER
# - PR_TITLE
setup_from_labeled_event() {
  label=$(jq -r '.label.name' < "${GITHUB_EVENT_PATH}")
  if echo "${label}" | grep "^bump:" ; then
    echo "Found label=${label}" >&2
    LABELS="${label}"
  else
    echo "Attached label name does not match with 'bump:'. label=${label}" >&2
    exit 0
  fi
  PR_NUMBER=$(jq -r '.pull_request.number' < "${GITHUB_EVENT_PATH}")
  PR_TITLE=$(jq -r '.pull_request.title' < "${GITHUB_EVENT_PATH}")
}

# Setup these env variables.
# - LABELS
# - PR_NUMBER
# - PR_TITLE
setup_from_push_event() {
  pull_request="$(list_pulls | jq ".[] | select(.merge_commit_sha==\"${GITHUB_SHA}\")")"
  LABELS=$(echo "${pull_request}" | jq '.labels | .[].name')
  PR_NUMBER=$(echo "${pull_request}" | jq -r .number)
  PR_TITLE=$(echo "${pull_request}" | jq -r .title)
}

list_pulls() {
  pulls_endpoint="https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls?state=closed&sort=updated&direction=desc"
  if [ -n "${INPUT_GITHUB_TOKEN}" ]; then
    curl -s -H "Authorization: token ${INPUT_GITHUB_TOKEN}" "${pulls_endpoint}"
  else
    echo "INPUT_GITHUB_TOKEN is not available. Subscequent GitHub API call may fail due to API limit." >&2
    curl -s "${pulls_endpoint}"
  fi
}

post_pre_status() {
  head_label="$(jq -r '.pull_request.head.label' < "${GITHUB_EVENT_PATH}" )"
  compare=""
  if [ -n "${CURRENT_VERSION}" ]; then
    compare="**Changes**:[${CURRENT_VERSION}...${head_label}](https://github.com/${GITHUB_REPOSITORY}/compare/${CURRENT_VERSION}...${head_label})"
  fi
  post_txt="🏷️ [[bumpr]](https://github.com/haya14busa/action-bumpr)
**Next version**:${NEXT_VERSION}
${compare}"
  FROM_FORK=$(jq -r '.pull_request.head.repo.fork' < "${GITHUB_EVENT_PATH}")
  if [ "${FROM_FORK}" = "true" ]; then
    post_warning "${post_txt}"
  else
    post_comment "${post_txt}"
  fi
}

post_post_status() {
  compare=""
  if [ -n "${CURRENT_VERSION}" ]; then
    compare="**Changes**:[${CURRENT_VERSION}...${NEXT_VERSION}](https://github.com/${GITHUB_REPOSITORY}/compare/${CURRENT_VERSION}...${NEXT_VERSION})"
  fi
  post_txt="🚀 [[bumpr]](https://github.com/haya14busa/action-bumpr) [Bumped!](https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID})
**New version**:[${NEXT_VERSION}](https://github.com/${GITHUB_REPOSITORY}/releases/tag/${NEXT_VERSION})
${compare}
"
  post_comment "${post_txt}"
}

# It assumes setup func is called beforehand.
# POST /repos/:owner/:repo/issues/:issue_number/comments
post_comment() {
  body_text="$1"
  endpoint="https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/comments"
  # Do not quote body_text for multiline comments.
  body="$(echo ${body_text} | jq -ncR '{body: input}')"
  curl -H "Authorization: token ${INPUT_GITHUB_TOKEN}" -d "${body}" "${endpoint}"
}

post_warning() {
  body_text=$(echo "$1" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/%0A/g')
  echo "::warning ::${body_text}"
}

# Get labels and Pull Request data.
ACTION=$(jq -r '.action' < "${GITHUB_EVENT_PATH}" )
if [ "${ACTION}" = "labeled" ]; then
  setup_from_labeled_event
else
  setup_from_push_event
fi

BUMP_LEVEL="${INPUT_DEFAULT_BUMP_LEVEL}"
if echo "${LABELS}" | grep "bump:major" ; then
  BUMP_LEVEL="major"
elif echo "${LABELS}" | grep "bump:minor" ; then
  BUMP_LEVEL="minor"
elif echo "${LABELS}" | grep "bump:patch" ; then
  BUMP_LEVEL="patch"
fi

if [ -z "${BUMP_LEVEL}" ]; then
  echo "PR with labels for bump not found. Do nothing."
  echo "::set-output name=skip::true"
  exit
fi
echo "Bump ${BUMP_LEVEL} version"

git fetch --tags -f # Fetch existing tags before bump.
# Fetch history as well because bump uses git history (git tag --merged).
git fetch --prune --unshallow
CURRENT_VERSION="$(bump current)" || true
NEXT_VERSION="$(bump ${BUMP_LEVEL})" || true

# Set next version tag in case existing tags not found.
if [ -z "${NEXT_VERSION}" ] && [ -z "$(git tag)" ]; then
	case "${BUMP_LEVEL}" in
		major)
			NEXT_VERSION="v1.0.0"
			;;
		minor)
			NEXT_VERSION="v0.1.0"
			;;
		patch)
			NEXT_VERSION="v0.0.1"
			;;
	esac
fi

if [ -z "${NEXT_VERSION}" ]; then
  echo "Cannot find next version."
  exit 1
fi
echo "::set-output name=current_version::${CURRENT_VERSION}"
echo "::set-output name=next_version::${NEXT_VERSION}"

TAG_MESSAGE="${NEXT_VERSION}: PR #${PR_NUMBER} - ${PR_TITLE}"
echo "::set-output name=message::${TAG_MESSAGE}"

if [ "${INPUT_DRY_RUN}" = "true" ]; then
  echo "DRY_RUN=true. Do not tag next version."
  echo "PR_NUMBER=${PR_NUMBER}"
  echo "PR_TITLE=${PR_TITLE}"
  echo "TAG_MESSAGE=${TAG_MESSAGE}"
  exit
fi

if [ "${ACTION}" = "labeled" ]; then
  post_pre_status
else
  # Set up Git.
  git config user.name "${GITHUB_ACTOR}"
  git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

  # Push the next tag.
  git tag -a "${NEXT_VERSION}" -m "${TAG_MESSAGE}"
  git push origin "${NEXT_VERSION}"

  # Post post-bumpr status on merge.
  post_post_status
fi
