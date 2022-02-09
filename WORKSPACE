load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_pkg",
    sha256 = "353b20e8b093d42dd16889c7f918750fb8701c485ac6cceb69a5236500507c27",
    urls = [
        "https://github.com/bazelbuild/rules_pkg/releases/download/0.5.0/rules_pkg-0.5.0.tar.gz",
    ],
)

http_archive(
    name = "rules_cc",
    sha256 = "b6f34b3261ec02f85dbc5a8bdc9414ce548e1f5f67e000d7069571799cb88b25",
    strip_prefix = "rules_cc-726dd8157557f1456b3656e26ab21a1646653405",
    urls = [
        "https://github.com/bazelbuild/rules_cc/archive/726dd8157557f1456b3656e26ab21a1646653405.tar.gz",
    ],
)

http_archive(
    name = "com_grail_bazel_toolchain",
    sha256 = "da607faed78c4cb5a5637ef74a36fdd2286f85ca5192222c4664efec2d529bb8",
    strip_prefix = "bazel-toolchain-0.6.3",
    urls = [
        "https://github.com/grailbio/bazel-toolchain/archive/refs/tags/0.6.3.tar.gz",
    ],
)

load("@com_grail_bazel_toolchain//toolchain:rules.bzl", "llvm_toolchain")

llvm_toolchain(
    name = "llvm_toolchain",
    llvm_version = "12.0.0",
)

load("@llvm_toolchain//:toolchains.bzl", "llvm_register_toolchains")

llvm_register_toolchains()

register_toolchains("//bazel/python:toolchain")

http_archive(
    name = "rules_python",
    sha256 = "43c007823228f88d6afe1580d00f349564c97e103309a234fa20a5a10a9ff85b",
    strip_prefix = "rules_python-54d1cb35cd54318d59bf38e52df3e628c07d4bbc",
    urls = [
        "https://github.com/grailbio-external/rules_python/archive/54d1cb35cd54318d59bf38e52df3e628c07d4bbc.tar.gz",
    ],
)

http_archive(
    name = "subpar",
    patch_args = ["-p1"],
    patches = [
        "//bazel/python:subpar_compiler_cli.patch",
        "//bazel/python:subpar_runtime_support.patch",
    ],
    sha256 = "b80297a1b8d38027a86836dbadc22f55dc3ecad56728175381aa6330705ac10f",
    strip_prefix = "subpar-2.0.0",
    urls = [
        "https://github.com/google/subpar/archive/2.0.0.tar.gz",
    ],
)

load("//third_party/python/cpython:cpython.bzl", cpython_repositories = "cpython")

cpython_repositories()

load("//third_party/zstd:zstd.bzl", zstd_repositories = "zstd")

zstd_repositories()

load("//bazel/python:repo.bzl", python_repositories = "repositories")

python_repositories()
