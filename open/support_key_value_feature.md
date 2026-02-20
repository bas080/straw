# Support Key value term in issue markdown

In the issue you can define key value things to later query on them.

We'll use the `?` at the start of a key value. This is inspired by url query params.

`?author=@bas080`

Here we can see that it is allowed to use other special tokens as the value.

The underlying markup created is.

```html
<span class="straw-keyvalue">
  <a ?author=</a><a>@bas080</a>
</span>
```

The user can either interact with the key value token by clicking the first anchor;
or by clicking on the mention token.

Note

- The anchors are not nested in eachother.
- The class on the span is how the code interops with browser code.

These changes require both #browser and #cli changes. For the cli changes
we could ?assign=@rage.


## Older suggestsions

**Candidates**

- key:value
- key=value

**examples**

- related=#a11y
- priority:1

\#feature
?assign=@bas080
