# Do not match on content when searching with slash

When searching for `/open` it should not match on arbitrary `/open` strings. It
should only match on the file path.

Other search operations might also need reconsideration but this issue is only
concerned about the path search.
