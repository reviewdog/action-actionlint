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
      - uses: actions/checkout@v2
      - uses: reviewdog/action-actionlint@v1
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
