# Add link to jump to file in github

This requires the defining of a source path. The source path in the case of github would be.

`https://github.com/bas080/straw/blob/master/straw/`

It will then append the path of the issue file to that source path.

When generating the straw html; one has to define the SOURCE_URL environment variable.

Work can be started on the html template. ?assigned=@bas080 to get this going.

An anchor with the word `source`. `<a href="${SOURCE_URL}/${PATH}">source</a>`

## Outdated

For now just supporting github is fine because we are using github.

Besides, this is configured in the template. The template at some point will be
configurable by the user.

?suggested-by=@rage #feature #github #cli #browser
