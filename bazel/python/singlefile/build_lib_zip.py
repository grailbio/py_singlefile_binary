import argparse
import hashlib
import inspect
import zipfile


def _parse_args():
    args = argparse.ArgumentParser()
    args.add_argument("--par", required=True)
    args.add_argument("--out", required=True)
    return args.parse_args()


SUPPORT_PATH = "subpar/runtime/support.py"

# This is concatenated onto @subpar//runtime:support.py to patch .par archive
# runtime initialization.
# TODO: Consider building our .zip archives without @subpar so this is no longer needed.
def _extract_files(archive_path):
    import os
    import os.path
    import tempfile
    import zipfile

    user_cache_dir = os.getenv("XDG_CACHE_HOME")
    if not user_cache_dir:
        user_cache_dir = os.path.expanduser("~/.cache")
    extract_dir = os.path.join(user_cache_dir, "grail_py_singlefile/v0/{digest}")

    if os.path.exists(extract_dir):
        _log("# reusing extracted dir %s to %s" % (archive_path, extract_dir))
        return extract_dir

    # TODO: Extract to tmp dir, then mv, to avoid corruption if earlier attempt failed.
    os.makedirs(os.path.dirname(extract_dir), exist_ok=True)
    extract_tmp_dir = tempfile.mkdtemp(prefix=extract_dir + ".")
    _log("# extracting %s to %s" % (archive_path, extract_tmp_dir))
    zf = zipfile.ZipFile(archive_path, mode="r")
    for member in zf.namelist():
        # Skip stdlib.
        if member.startswith("lib/"):
            continue
        zf.extract(member, extract_tmp_dir)
    zf.close()
    os.rename(extract_tmp_dir, extract_dir)

    return extract_dir


def main():
    args = _parse_args()
    with open(args.par, "rb") as par_file:
        digest = hashlib.sha256(par_file.read()).hexdigest()
        par_file.seek(0)
        with zipfile.ZipFile(par_file) as par:
            with zipfile.ZipFile(args.out, mode="a") as out:
                for info in par.infolist():
                    with par.open(info, "r") as entry_file:
                        entry_content = entry_file.read()

                    if info.filename == SUPPORT_PATH:
                        support_tail_src = inspect.getsource(_extract_files)
                        entry_content = (
                            entry_content.decode("utf-8")
                            + support_tail_src.format(digest=digest)
                        ).encode("utf-8")

                    out.writestr(info, entry_content)


if __name__ == "__main__":
    main()
