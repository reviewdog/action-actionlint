# GitHub Action: Run actionlint with reviewdog

This action runs [actionlint](https://github.com/rhysd/actionlint) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience.

## Inputs

### `github_token`

**Required**. Default is `${{ github.token }}`.

### `actionlint_flags`

Optional. actionlint flags. (actionlint -oneline `<actionlint_flags>`)

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog.

### `workdir`

Optional. Working directory relative to the root directory.

### `reporter`

Optional. Reporter of reviewdog command [github-pr-check,github-pr-review].
It's same as `-reporter` flag of reviewdog.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [added,diff_context,file,nofilter].
Default is added.

### `fail_on_error`

Optional.  Exit code for reviewdog when errors are found [true,false]
Default is `false`.

### `reviewdog_flags`

Optional. Additional reviewdog flags
