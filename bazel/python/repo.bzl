load("//bazel:platform.bzl", "detect_platform")

# Keys are targets in @bazel_tools//src/conditions:*.
_platform_defs = {
    "darwin_x86_64": struct(
        cpython_repo = "@com_github_indygreg_python_build_standalone_cpython_x86_64_apple_darwin_pgo",
        python3 = "@//bazel/python:_repo_python3.darwin.bash",
    ),
    "linux_x86_64": struct(
        cpython_repo = "@com_github_indygreg_python_build_standalone_cpython_x86_64_unknown_linux_gnu_pgo",
        python3 = "@//bazel/python:_repo_python3.linux.bash",
    ),
}

REPO_NAME = "python_interpreter"

def repositories():
    _python(name = REPO_NAME)

_repo_build_tmpl = """
load("@rules_cc//cc:defs.bzl", "cc_library")

exports_files(["python3"])

cc_library(
    name = "headers",
    hdrs = glob(["include/python3.7m/**"]),
    strip_include_prefix = "include/python3.7m",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "files",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)

alias(
    name = "libpython",
    actual = "{cpython_repo}//:libpython",
    visibility = ["//visibility:public"],
)

alias(
    name = "stdlib.zip",
    actual = "{cpython_repo}//:stdlib.zip",
    visibility = ["//visibility:public"],
)
"""

def _python_impl(rctx):
    platform = detect_platform(rctx)
    platform_def = _platform_defs[platform]

    # Note: We resolve the path to cpython early because it will trigger restarting.
    # See: https://docs.bazel.build/versions/4.2.1/skylark/repository_rules.html#when-is-the-implementation-function-executed
    # We also avoid using a label-typed `repository_rule.attrs` entry because we *do not*
    # want to prefetch; we only need the platform-matched cpython.
    cpython_workspace = rctx.path(Label(platform_def.cpython_repo + "//:WORKSPACE"))
    repo_python3 = rctx.path(Label(platform_def.python3))

    repo_init = rctx.path(rctx.attr._repo_init)

    # Link python3 first so we can use it for repo init (it isolates python from user packages).
    rctx.symlink(repo_python3, "python3")

    exec_result = rctx.execute([
        repo_init,
        cpython_workspace,
        "pip==21.0.1",
        "wheel==0.36.2",
    ], environment = {"PYTHONPATH": ""})
    if exec_result.return_code:
        fail("python repo init: \nstdout: %s\nstderr: %s" % (exec_result.stdout, exec_result.stderr))

    rctx.file("BUILD", _repo_build_tmpl.format(cpython_repo = platform_def.cpython_repo))

_python = repository_rule(
    implementation = _python_impl,
    attrs = {
        "_repo_init": attr.label(
            default = "@//bazel/python:_repo_init.bash",
            allow_single_file = True,
        ),
    },
)
