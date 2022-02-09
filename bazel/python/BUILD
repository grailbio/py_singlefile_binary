package(default_visibility = ["//visibility:public"])

load("@bazel_tools//tools/python:toolchain.bzl", "py_runtime_pair")
load(":repo.bzl", "REPO_NAME")

py_runtime(
    name = "py3_runtime",
    files = ["@%s//:files" % REPO_NAME],
    interpreter = "@%s//:python3" % REPO_NAME,
    python_version = "PY3",
)

py_runtime_pair(
    name = "py_runtime_pair",
    py3_runtime = ":py3_runtime",
)

toolchain(
    name = "toolchain",
    toolchain = ":py_runtime_pair",
    toolchain_type = "@bazel_tools//tools/python:toolchain_type",
)
