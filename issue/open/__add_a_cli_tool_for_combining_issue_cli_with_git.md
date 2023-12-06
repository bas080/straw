# Add a cli tool for combining issue cli with git

## Use cases

- Create a new branch based on an issue title.
- Create a commit based on an issue.

## Examples

```bash
git issue --branch ./issue/open/some-issue.md

# git checkout "some-branch-name-based-on-issue-title"

git issue --commit ./issue/open/some-issue.md

# git commit -f <(uses a commit message friendly version of the issue)
```

author:@bas080
priority:low
