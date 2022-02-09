load(
    "@bazel_tools//tools/build_defs/repo:utils.bzl",
    "update_attrs",
    "workspace_and_buildfile",
)
load("//bazel:platform.bzl", "detect_platform")

def _zstd_http_archive_impl(rctx):
    if rctx.attr.build_file and rctx.attr.build_file_content:
        fail("Only one of build_file and build_file_content can be provided.")
    if rctx.attr.workspace_file and rctx.attr.workspace_file_content:
        fail("Only one of workspace_file and workspace_file_content can be provided.")
    if rctx.attr.type != "tar.zst":
        fail("""Only supported `type` is `"tar.zst"`, for now.""")

    platform = detect_platform(rctx)
    if platform == "darwin_x86_64":
        zstd = rctx.path(Label("@zstd_darwin//file:zstd"))
    elif platform == "linux_x86_64":
        zstd = rctx.path(Label("@zstd_linux//file:zstd"))
    else:
        fail("platform not supported")

    download_name = "__grail_download.zstd"
    download_info = rctx.download(
        rctx.attr.urls,
        download_name,
        rctx.attr.sha256,
    )
    result = rctx.execute(
        [
            rctx.path(rctx.attr._extract),
            zstd,
            rctx.path(download_name),
        ],
        working_directory = ".",
    )
    if result.return_code != 0:
        fail("failed to extract zstd archive:\nstdout:\n{}\nstderr:\n{}".format(result.stdout, result.stderr))
    if not rctx.delete(download_name):
        fail("failed to clean up zstd archive")

    # Note: Remaining steps are copied from `http_archive`'s implementation.
    # We may want to keep these in sync in the future, and eventually delete this when that rule
    # supports zstd.

    workspace_and_buildfile(rctx)

    # TODO: Implement patching if some future `zstd_http_archive` requires it.
    return update_attrs(rctx.attr, _zstd_http_archive_attrs.keys(), {"sha256": download_info.sha256})

_zstd_http_archive_attrs = {
    "urls": attr.string_list(
        mandatory = True,
        doc = "A list of URLs to a file that will be made available to Bazel. See http_archive.",
    ),
    "sha256": attr.string(
        doc = "The expected SHA-256 of the file downloaded. See http_archive.",
    ),
    "type": attr.string(
        doc = """The archive type of the downloaded file. For now, only `"tar.zst"` is allowed.""",
    ),
    "build_file": attr.label(
        doc = "The file to use as the BUILD file for this repository. See http_archive.",
        allow_single_file = True,
    ),
    "build_file_content": attr.string(
        doc = "The content for the BUILD file for this repository. See http_archive.",
    ),
    "workspace_file": attr.label(
        doc = "The file to use as the `WORKSPACE` file for this repository. See http_archive.",
        allow_single_file = True,
    ),
    "workspace_file_content": attr.string(
        doc = "The content for the WORKSPACE file for this repository. See http_archive.",
    ),
    "_extract": attr.label(default = "@//bazel/zstd:_extract.bash"),
}

zstd_http_archive = repository_rule(
    attrs = _zstd_http_archive_attrs,
    implementation = _zstd_http_archive_impl,
    doc = """
Partial implementation of http_archive supporting zstd.

TODO: Remove after bazel supports this natively.
See: https://github.com/bazelbuild/bazel/issues/10342
""",
)
