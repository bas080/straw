# Straw 🌾

Simple issues/notes using markdown files and a thin CLI wrapper.

## Reasoning

Because you want something portable and simple.

## Usage

```sh
straw --help
```

## Build

> Requires `opam` to be installed.

```sh
opam install . --deps-only --with-test
opam exec -- dune build --release
opam exec -- dune runtest
```

## Releases

[https://github.com/bas080/straw/releases][releases]

> You can get a binary there or build your own.

[releases]:https://github.com/bas080/straw/releases
