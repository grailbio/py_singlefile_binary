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

$ ls -lh bazel-bin/example/example
-r-xr-xr-x 1 ubuntu ubuntu 36M Feb  9 21:04 bazel-bin/example/example

$ file bazel-bin/example/example
bazel-bin/example/example: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[md5/uuid]=9bfcb311068bf4ad4538f2b0798ea2c2, not stripped

$ unzip -l bazel-bin/example/example | tail
warning [bazel-bin/example/example]:  35285712 extra bytes at beginning or within zipfile
  (attempting to process anyway)
    81094  1980-01-01 00:00   lib/python3.7/zipfile.py
      194  1980-01-01 00:00   __main__.py
    14943  1980-01-01 00:00   __main__/example/example.par.py_binary
    14943  1980-01-01 00:00   __main__/example/example.par.py_binary_no_interpreter
       23  1980-01-01 00:00   __main__/example/example.py
        0  1980-01-01 00:00   subpar/__init__.py
        0  1980-01-01 00:00   subpar/runtime/__init__.py
    13303  1980-01-01 00:00   subpar/runtime/support.py
---------                     -------
 62732036                     2449 files
 ```
