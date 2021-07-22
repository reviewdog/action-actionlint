#!/usr/bin/env bash

set -uex

# Set up variables.
TAG="${INPUT_TAG:-${GITHUB_REF#refs/tags/}}" # v1.2.3
MINOR="${TAG%.*}"                            # v1.2
MAJOR="${MINOR%.*}"                          # v1
MESSAGE="Release ${TAG}"

# Build Docker Image
docker build -t "ghcr.io/$GITHUB_REPOSITORY:$TAG" .
printenv GITHUB_TOKEN | docker login ghcr.io --username "${GITHUB_REPOSITORY%/*}" --password-stdin
docker push "ghcr.io/$GITHUB_REPOSITORY:$TAG"
docker logout ghcr.io

# Set up Git.
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# checkout releases branch
git checkout main
git checkout -b "releases/$MAJOR" "origin/releases/$MAJOR" || git checkout -b "releases/$MAJOR" main
git merge -X theirs --no-ff -m "Merge branch 'main' into releases/$MAJOR" main || true

# configure to use the pre-built image
git checkout main -- action.yml
perl -i -pe "s(image:\\s*[\"']?Dockerfile[\"']?)(image: 'docker://ghcr.io/$GITHUB_REPOSITORY:$TAG')" action.yml
git add action.yml
git commit -m "bump $TAG"
git push origin "releases/$MAJOR"

# Update MAJOR/MINOR tags
git tag -fa "${MINOR}" -m "${MESSAGE}"
git tag -fa "${MAJOR}" -m "${MESSAGE}"
git tag -a "$TAG" -m "$MESSAGE"

# Push
git push origin "$TAG"
git push --force origin "${MINOR}"
git push --force origin "${MAJOR}"
