def detect_os(rctx):
    """
    Detects the host operating system.

    Args:
        rctx: repository_ctx

    Returns:
        One of the targets in @platforms//os:*.
    """
    os_name = rctx.os.name.lower()
    if os_name.startswith("mac os"):
        return "darwin"
    elif os_name == "linux":
        return "linux"
    elif os_name.startswith("windows"):
        return "windows"
    else:
        fail("unrecognized os_name %s" % os_name)

_KNOWN_CPUS = ("x86_64", "arm64")

def detect_cpu(rctx):
    """
    Detects the host CPU.

    Args:
        rctx: repository_ctx

    Returns:
        One of the targets in @platforms//cpu:*.
    """
    uname = rctx.which("uname")
    if not uname:
        fail("cannot detect host CPU: `uname` not found on path")
    res = rctx.execute(["uname", "-m"])
    if res.return_code == 0:
        cpu = res.stdout.strip()
        if cpu in _KNOWN_CPUS:
            return cpu
    fail("failed to detect host CPU with uname: stdout:\n%s\nstderr:\n%s" % (res.stdout, res.stderr))

def detect_platform(rctx):
    """
    Detects the host operating system + CPU.

    Args:
        rctx: repository_ctx

    Returns:
        One of the targets in @bazel_tools//src/conditions:*.
        Note that these use `darwin` instead of `macos` (as of Bazel 4.2).
    """
    os = detect_os(rctx)
    if os == "macos":
        os = "darwin"
    cpu = detect_cpu(rctx)
    return "%s_%s" % (os, cpu)
