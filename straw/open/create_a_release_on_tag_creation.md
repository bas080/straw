# Create a release on tag creation

It #must create a new release by pushing a new git tag.

It #could also populate the release body with release notes that are generated
using some git changelog tool. An option for such a tool could be
[npm:auto-changelog][2].

@rage has done this before and shared his [previous work and experience][1].

## Requirements

- The commits since last release do not contain fixup or wip commits messages.
- Update the changelog with a git log to changelog tool.
- Creates a github release with the cli build for that specific tag version.

author:@bas080
priority:medium

[1]: https://github.com/Siemplexus/DBIx-Class-Storage-DBI-MariaDB/blob/main/.github/workflows/release.yml
[2]: https://www.npmjs.com/package/auto-changelog
