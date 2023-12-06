# Add a cli tool for combining issue cli with git

A single command for working with issues to create branches and commits based
on issues.

## Use cases

Create a new branch and an empty commit with the issue as the commit message.

## Examples

```bash
git issue ./issue/open/some-issue.md

# git checkout "issue/some-issue"
# git commit --template <(uses a commit message friendly version of the issue)
```

@bas080 is trying a quick and dirty bash version on his local machine.

author:@bas080
priority:low
