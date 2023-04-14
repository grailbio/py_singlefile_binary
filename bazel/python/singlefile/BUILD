load("@bazel_skylib//rules:native_binary.bzl", "native_test")
load(":rules.bzl", "py_singlefile_binary")
load("//third_party/python:requirements.bzl", "requirement")

py_singlefile_binary(
    name = "numpy_bin",
    srcs = ["numpy_test.py"],
    main = "numpy_test.py",
    visibility = ["//go/src/grail.com/bazel/python/singlefile:__pkg__"],
    deps = [requirement("numpy")],
)

native_test(
    name = "numpy_test",
    src = "numpy_bin",
    out = "numpy_test",
)
