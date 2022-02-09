load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

def zstd():
    http_archive(
        name = "com_github_facebook_zstd",
        build_file = "//third_party/zstd:BUILD.zstd",
        sha256 = "e88ec8d420ff228610b77fba4fbf22b9f8b9d3f223a40ef59c9c075fcdad5767",
        strip_prefix = "zstd-1.4.3",
        urls = [
            "https://github.com/facebook/zstd/releases/download/v1.4.3/zstd-1.4.3.tar.gz",
        ],
    )

    http_file(
        name = "zstd_darwin",
        downloaded_file_path = "zstd",
        executable = True,
        sha256 = "ffdcbaa85c1d9c3ccfdd8715e6b31410f4fd992101ebf61c9adcdba12dcde73c",
        urls = ["https://s3-us-west-2.amazonaws.com/grail-bin-public/darwin/amd64/2022-01-19.joshnewman-140748/zstd"],
    )

    http_file(
        name = "zstd_linux",
        downloaded_file_path = "zstd",
        executable = True,
        sha256 = "8f5fc14065161612064dafc3e7a96e4b8ec539151861659b0ea07a5b8fddf26d",
        urls = ["https://s3-us-west-2.amazonaws.com/grail-bin-public/linux/amd64/2022-01-19.joshnewman-220104/zstd"],
    )
