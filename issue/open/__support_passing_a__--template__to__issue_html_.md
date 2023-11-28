# Support passing a `--template` to `issue html`

```bash
issue html --template=./issue/template.html
```

In this example we stored a template in the issue directory to be used to
generate a richer and interactive issues webpage.

The template contains a comment `<!--issues-->` that is replaced with the
output of `issue html`.

