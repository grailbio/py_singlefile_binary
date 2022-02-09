load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("//bazel/python/singlefile:rules.bzl", "cat_executable")

cc_library(
    name = "libpython",
    linkopts = select({
        # TODO: Use bazel dependencies instead of system ones, if possible.
        "@platforms//os:linux": [
            "-l:libcrypt.a",
            "-l:libutil.a",
            "-l:libnsl.a",
        ],
        "@platforms//os:macos": [
            "-framework AppKit",
            "-framework CoreGraphics",
            "-lreadline",
        ],
    }),
    linkstatic = True,
    deps = [
        "@python_interpreter//:libpython",
    ],
)

cc_library(
    name = "self_exe_path",
    srcs = ["self_exe_path.c"],
)

# Python interpreter binary that expects to have a .zip file concatenated onto itself before execution.
# The .zip file should contain the standard library in lib/python*.
cc_binary(
    name = "python_zip_base",
    srcs = ["python.c"],
    copts = ["-DPy_BUILD_CORE"],
    visibility = ["//visibility:public"],
    deps = [
        "libpython",
        "self_exe_path",
    ],
)

# Python interpreter binary that expects to have a .zip file concatenated onto itself before execution.
# The .zip file should contain the standard library in lib/python* plus a top-level __main__.py
# defining a self-executing Python .zip (see PEP 441).
cc_binary(
    name = "python_selfexe_zip_base",
    srcs = ["python.c"],
    copts = [
        "-DGRAIL_PYTHON_EXEC_SELF_ZIP",
        "-DPy_BUILD_CORE",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "libpython",
        "self_exe_path",
    ],
)

cat_executable(
    name = "python_with_stdlib",
    srcs = [
        "python_zip_base",
        "@python_interpreter//:stdlib.zip",
    ],
    visibility = ["//visibility:public"],
)
