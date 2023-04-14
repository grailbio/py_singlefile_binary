load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")
load("@rules_pkg//:pkg.bzl", "pkg_zip")
load("//bazel/python:repo.bzl", "EXE_NAME", "REPO_NAME")
load("//bazel/python/singlefile:rules.bzl", "CACHE_KEY_FILE")

go_library(
    name = "go_default_library",
    srcs = ["base.go"],
    importpath = "grail.com/bazel/python/singlefile/base",
    visibility = ["//visibility:public"],
    deps = [
        "//go/src/github.com/grailbio/base/must:go_default_library",
        "//go/src/github.com/grailbio/base/traverse:go_default_library",
    ],
)

go_binary(
    name = "base",
    embed = [":go_default_library"],
    visibility = ["//visibility:public"],
    x_defs = {
        "grail.com/bazel/python/singlefile/base.pythonBinName": "%s/%s" % (REPO_NAME, EXE_NAME),
        "grail.com/bazel/python/singlefile/base.zipCacheFile": CACHE_KEY_FILE,
    },
)
