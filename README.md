# py_singlefile_binary

This repository defines [Bazel](https://bazel.build/) rules for building self-contained
Python executables, including interpreter + standard library + application.

It's a proof-of-concept that we ([@grailbio](https://github.com/grailbio)) are using for some developer tools.
It's not extensively tested nor designed for reuse nor supported by us. It was extracted
out of our internal repository so it includes a few patches and non-current dependency versions.

Usage:
```
$ bazel run //example
...
INFO: Build completed successfully, 1 total action
Hello, world!
```
