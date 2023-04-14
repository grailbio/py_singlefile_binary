load("@io_bazel_rules_go//go:def.bzl", "go_test")

go_test(
    name = "go_default_test",
    srcs = ["numpy_parallel_test.go"],
    data = ["//bazel/python/singlefile:numpy_bin"],
    deps = [
        "//go/src/github.com/grailbio/base/traverse:go_default_library",
        "@com_github_stretchr_testify//require:go_default_library",
        "@io_bazel_rules_go//go/tools/bazel:go_default_library",
    ],
)
