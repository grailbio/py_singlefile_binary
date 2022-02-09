load("@subpar//:subpar.bzl", "parfile")
load("//bazel/python:repo.bzl", "REPO_NAME")

def par_binary(
        name,
        main = None,
        interpreter = "/usr/bin/env python3",
        visibility = None,
        **kwargs):
    """
    Generate a par binary, which is a single file containing a Python main program and libraries.
    """
    main = main or (name + ".py")
    native.py_binary(
        name = name + ".py_binary",
        main = main,
        **kwargs
    )
    _strip_interpreter_runfiles(
        name = name + ".py_binary_no_interpreter",
        src = name + ".py_binary",
    )
    parfile(
        name = name,
        compiler = "@subpar//compiler",  # Avoid the repository vs. system interpreter issue.
        compiler_args = ["--interpreter={}".format(interpreter)],
        default_python_version = "PY3",
        main = main,
        src = name + ".py_binary_no_interpreter",
        visibility = visibility,
    )

def _strip_interpreter_runfiles_impl(ctx):
    info = ctx.attr.src[DefaultInfo]

    # Copy src's executable because Bazel requires that a rule create its own executable output.
    executable_in = [f for f in ctx.files.src if f.basename == ctx.attr.src.label.name][0]
    executable_out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.run(
        executable = "cp",
        inputs = [executable_in],
        outputs = [executable_out],
        arguments = [executable_in.path, executable_out.path],
    )

    runfiles = ctx.runfiles(
        files = [
            f
            for f in info.default_runfiles.files.to_list()
            if not f.dirname.split("/", 2)[:2] == ["external", REPO_NAME]
        ],
    )
    runfiles = runfiles.merge(ctx.runfiles(files = [executable_out]))

    return [
        DefaultInfo(
            files = info.files,
            data_runfiles = info.data_runfiles,
            default_runfiles = runfiles,
            executable = executable_out,
        ),
        ctx.attr.src[PyInfo],
    ]

_strip_interpreter_runfiles = rule(
    implementation = _strip_interpreter_runfiles_impl,
    attrs = {
        "src": attr.label(
            mandatory = True,
            providers = [PyInfo, DefaultInfo],
        ),
    },
    doc = """
Roughly filters a py_binary to remove our python interpreter from its runfiles.
""",
)
