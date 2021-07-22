# action-bumpr

**action-bumpr** bumps semantic version tag on merging Pull Requests with
specific lables (`bump:major`,`bump:minor`,`bump:patch`).

![action-bumpr image](https://user-images.githubusercontent.com/3797062/72686834-dc19a980-3b3b-11ea-9a25-3c5be36d45b1.png)

[![Test](https://github.com/haya14busa/action-bumpr/workflows/Test/badge.svg)](https://github.com/haya14busa/action-bumpr/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/haya14busa/action-bumpr/workflows/reviewdog/badge.svg)](https://github.com/haya14busa/action-bumpr/actions?query=workflow%3Areviewdog)
[![release](https://github.com/haya14busa/action-bumpr/workflows/release/badge.svg)](https://github.com/haya14busa/action-bumpr/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/haya14busa/action-bumpr?logo=github&sort=semver)](https://github.com/haya14busa/action-bumpr/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

[![example](https://user-images.githubusercontent.com/3797062/81489783-edd2b880-92b4-11ea-84d5-ea54f3b3fb16.png)](https://github.com/haya14busa/action-bumpr/pull/18)

## Input

```yaml
inputs:
  default_bump_level:
    description: "Default bump level if labels are not attached [major,minor,patch]. Do nothing if it's empty"
  dry_run:
    description: "Do not actually tag next version if it's true"
outputs:
  current_version:
    description: "current version"
  next_version:
    description: "next version"
  skip:
    description: "True if release is skipped. e.g. No labels attached to PR."
  message:
    description: "Tag message"
```

## Usage

### Simple

```yaml
name: release
on:
  push:
    branches:
      - master
  pull_request:
    types:
      - labeled

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      # Bump version on merging Pull Requests with specific labels.
      # (bump:major,bump:minor,bump:patch)
      - uses: haya14busa/action-bumpr@v1
```

### Integrate with other release related actions.

Integrate with
[haya14busa/action-update-semver](https://github.com/haya14busa/action-update-semver)
to update major and minor tags on semantic version tag release (e.g. update v1
and v1.2 tag on v1.2.3 release).

```yaml
name: release
on:
  push:
    branches:
      - master
    tags:
      - 'v*.*.*'
  pull_request:
    types:
      - labeled

jobs:
  release:
    if: github.event.action != 'labeled'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      # Bump version on merging Pull Requests with specific labels.
      # (bump:major,bump:minor,bump:patch)
      - id: bumpr
        if: "!startsWith(github.ref, 'refs/tags/')"
        uses: haya14busa/action-bumpr@v1

      # Update corresponding major and minor tag.
      # e.g. Update v1 and v1.2 when releasing v1.2.3
      - uses: haya14busa/action-update-semver@v1
        if: "!steps.bumpr.outputs.skip"
        with:
          github_token: ${{ secrets.github_token }}
          tag: ${{ steps.bumpr.outputs.next_version }}
  release-check:
    if: github.event.action == 'labeled'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Post bumpr status comment
        uses: haya14busa/action-bumpr@v1
```

### Badge

```md
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)
```

### Note
action-bumpr uses push on master event to run workflow instead of pull_request
closed (merged) event because github token doesn't have write permission
for pull_request from fork repository.
