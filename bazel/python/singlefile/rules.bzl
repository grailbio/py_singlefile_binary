load("@rules_python//python:defs.bzl", "py_binary")
load("//bazel/python:repo.bzl", "LIB_NAME", "REPO_NAME")

# CACHE_KEY_FILE names a file within each py_singlefile_binary zip archive. Its contents are a hash
# of the Python application that's suitable for memoizing extraction, so that subsequent executions
# can be faster. Of course, the singlefile runtime could compute such a key itself, but that could
# actually be a lot of work for very large applications (> 1 GiB, for some GPU programs), so we
# do this once at build time.
CACHE_KEY_FILE = ".grail_py_singlefile_cache_key"

def py_singlefile_binary(
        name,
        main = None,
        visibility = None,
        testonly = None,
        **kwargs):
    """
    Experimental alternative to .par that bundles the Python interpreter in the same file.
    It doesn't require a system Python installation to run (easy to package in Docker, etc.).
    """
    py_binary(
        name = name + ".py_binary",
        main = main or name + ".py",
        testonly = testonly,
        **kwargs
    )
    native.filegroup(
        name = name + ".py_zip",
        srcs = [name + ".py_binary"],
        # As of this writing, python_zip_file isn't very clearly documented, though it is mentioned:
        #   * By a Bazel team member: https://github.com/bazelbuild/bazel/issues/3530#issuecomment-536454925
        #   * In subpar's deprecation notice: https://github.com/google/subpar/tree/5c486705da7fece4739015ce566423a8fd89916f#status
        # It's the complement to Bazel's `--build_python_zip` flag:
        # http://web.archive.org/web/20230108052514/https://bazel.build/reference/command-line-reference#flag--build_python_zip
        output_group = "python_zip_file",
        testonly = testonly,
    )
    native.genrule(
        name = name + ".gen_keyed.zip",
        outs = [name + ".keyed.zip"],
        srcs = [name + ".py_zip"],
        cmd = " && ".join([
            # Note: Similar to `cp`, but that may preserve the read-only mode of the input, and
            # the flags to fix that may differ by system (especially GNU/Linux vs. macOS).
            "cat <$< >$@",
            # Note: @bazel_tools is undocumented: https://github.com/bazelbuild/bazel/issues/4301
            # See source: https://github.com/bazelbuild/bazel/blob/5.3.0/tools/build_defs/hash/BUILD#L16-L20
            "$(location @bazel_tools//tools/build_defs/hash:sha256) $< %s" % CACHE_KEY_FILE,
            "zip --quiet $@ %s" % CACHE_KEY_FILE,
            # Delete site-packages to save space.
            # This includes things like numpy (see repo.bzl), which is large, and also redundant
            # because apps that use numpy will fetch it separately as a bazel dependency.
            "zip --quiet --delete $@ 'runfiles/%s/lib/%s/site-packages/*'" % (REPO_NAME, LIB_NAME),
        ]),
        tools = ["@bazel_tools//tools/build_defs/hash:sha256"],
        testonly = testonly,
    )
    _cat(
        name = name,
        srcs = [
            "//go/src/grail.com/bazel/python/singlefile/base",
            name + ".keyed.zip",
        ],
        testonly = testonly,
        visibility = visibility,
    )

def _cat_impl(ctx):
    output = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [output],
        inputs = ctx.files.srcs,
        # Create a self-extracting executable zip archive, which is simply a zip file prepended
        # with some executable. See `man zip`.
        # zip --adjust-sfx fixes offsets to account for our concatenation, because the Go stdlib zip
        # reader does not handle this the same way `unzip`, Python, etc. do.
        # See: https://github.com/golang/go/issues/10464#issuecomment-761745500.
        # TODO: Remove this after upgrading to go1.19 (https://go.dev/doc/go1.19#archive/zip).
        command = "cat >$1 ${@:2} && zip --quiet --adjust-sfx $1",
        arguments = [output.path] + [file.path for file in ctx.files.srcs],
        mnemonic = "CatExecutable",
    )
    return DefaultInfo(executable = output)

_cat = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            allow_files = True,
            mandatory = True,
        ),
    },
    executable = True,
    implementation = _cat_impl,
)
