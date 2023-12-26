# Make it easy to link issues to one and other

With github issue tracker you can use the #<issue-number> to reference other
issues.

The hashtag is used for labels. Either rethink this or use something
else to reference issues.

Both @rage and @bas080 agree that `!` is a good candidate.

For this to work we also need a way to assign the id to an issue file. Possible
implementations:

- Edit the file meta data to include an id. This requires the use of the `cli`
  and is less transparent. Suggested by @rage.
- Have it be part of the filename. This requires a convention to be followed.
- Have each issue be placed in a directory that has an issue id.
  `/open/abc12/my-issue.md`. This also allows bundling possible dependencies
  like images within the issue.

priority:high
