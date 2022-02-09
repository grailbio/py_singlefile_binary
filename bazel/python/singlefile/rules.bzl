load("//bazel/python:par.bzl", "par_binary")

def py_singlefile_binary(
        name,
        main = None,
        zip_safe = False,
        visibility = None,
        testonly = None,
        **kwargs):
    """
    Experimental alternative to .par that bundles the Python interpreter in the same file.
    It doesn't require a system Python installation to run (easy to package in Docker, etc.).
    """

    # TODO: Consider using github.com/indygreg/PyOxidizer instead. First we need to upgrade to 3.8+.
    # Also, make sure it supports extension modules (like numpy, tensorflow, etc.) we need,
    # works with jupyter kernels, etc.

    par_binary(
        name = name + ".par",
        main = main,
        visibility = visibility,
        testonly = testonly,
        **kwargs
    )
    native.genrule(
        name = "gen_" + name + ".stdlib.zip",
        srcs = [
            name + ".par",
            "@python_interpreter//:stdlib.zip",
        ],
        outs = [name + ".stdlib.zip"],
        exec_tools = ["//bazel/python/singlefile:build_lib_zip"],
        cmd = " && ".join([
            "cp $(location @python_interpreter//:stdlib.zip) $@",
            "chmod 755 $@",
            "$(location //bazel/python/singlefile:build_lib_zip) --par $(location %s.par) --out $@" % name,
        ]),
        testonly = testonly,
        visibility = visibility,
    )
    cat_executable(
        name = name,
        srcs = [
            "//third_party/python/cpython:python_selfexe_zip_base",
            name + ".stdlib.zip",
        ],
        testonly = testonly,
        visibility = visibility,
    )

def _cat_impl(ctx):
    output = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [output],
        inputs = ctx.files.srcs,
        command = "cat >$1 ${@:2}",
        arguments = [output.path] + [file.path for file in ctx.files.srcs],
        mnemonic = "CatExecutable",
    )
    return DefaultInfo(executable = output)

cat_executable = rule(
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
