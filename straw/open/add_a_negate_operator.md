# Add a negate operator

If you would for example exclude all /closed items you could write `-/closed`

**Candidates**

`-` and `!`

I have implemented the `not` for negation and decided to instead opt for the `-`.

Currently this behavior is implemented but not document in the usages.

## Tasks

- [x] Document negation.
- [ ] Give visual feedback in filter buttons that it is a negated token.
- [ ] Have the UI report correctly on count matches for negated tokens.
