load("//bazel/zstd:rules.bzl", "zstd_http_archive")

def cpython():
    zstd_http_archive(
        name = "com_github_indygreg_python_build_standalone_cpython_x86_64_unknown_linux_gnu_pgo",
        sha256 = "c6d6256d13e929e77e7ee6e53470fe63ad19d173fee6d56bb1b2dbda67081543",
        type = "tar.zst",
        urls = [
            "https://github.com/indygreg/python-build-standalone/releases/download/20200822/cpython-3.7.9-x86_64-unknown-linux-gnu-pgo-20200823T0036.tar.zst",
        ],
        build_file = "@//third_party/python/cpython:BUILD.cpython",
    )

    zstd_http_archive(
        name = "com_github_indygreg_python_build_standalone_cpython_x86_64_apple_darwin_pgo",
        sha256 = "53657e7712cc7b24491fb1fc66dcc8f47a577fc77df137178746987ba4c5afb8",
        type = "tar.zst",
        urls = [
            "https://github.com/indygreg/python-build-standalone/releases/download/20200823/cpython-3.7.9-x86_64-apple-darwin-pgo-20200823T2228.tar.zst",
        ],
        build_file = "@//third_party/python/cpython:BUILD.cpython",
    )
