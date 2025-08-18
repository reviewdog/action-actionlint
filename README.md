# GitHub Action: Run actionlint with reviewdog

This action runs [actionlint](https://github.com/rhysd/actionlint) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience.

![example of broken workflow](https://user-images.githubusercontent.com/1157344/126649071-200f4e40-c507-4a17-952f-2ed7f30d8df7.png)

[shellcheck](https://github.com/koalaman/shellcheck) and [pyflakes](https://github.com/PyCQA/pyflakes) integrations are enabled by default.

![example of shellcheck](https://user-images.githubusercontent.com/1157344/126648951-b712cfbf-e12f-4d4b-842e-2c15b5181ae5.png)
![example of pyflakes](https://user-images.githubusercontent.com/1157344/126649211-c4943c9c-7238-486c-9b28-8e39bd172a8a.png)

## Example usages

```yaml
name: reviewdog
on: [pull_request]
jobs:
  actionlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: reviewdog/action-actionlint@a5524e1c19e62881d79c1f1b9b6f09f16356e281 # v1.65.2
```

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

### `reporter`

Optional. Reporter of reviewdog command [github-pr-check,github-pr-review].
It's same as `-reporter` flag of reviewdog.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [added,diff_context,file,nofilter].
Default is file.

### `fail_level`

Optional. If set to `none`, always use exit code 0 for reviewdog. Otherwise, exit code 1 for reviewdog if it finds at least 1 issue with severity greater than or equal to the given level.
Possible values: [`none`, `any`, `info`, `warning`, `error`]
Default is `none`.

### `fail_on_error`

Deprecated, use `fail_level` instead.
Optional.  Exit code for reviewdog when errors are found [true,false]
Default is `false`.

### `reviewdog_flags`

Optional. Additional reviewdog flags
