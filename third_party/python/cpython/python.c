#include "Python.h"

#include <stdio.h>
#include <stdlib.h>

// Note: This program allocates memory a few times and doesn't free it.
// The allocations are quite small so we're ok with the leak.

char *self_exe_path();

void add_self_exec_argv(int *argc, char ***argv) {
  char **added = (char **)malloc((*argc + 1) * sizeof(char *));
  if (added == NULL) {
    fprintf(stderr, "error from malloc\n");
    abort();
  }
  added[0] = (*argv)[0];
  added[1] = self_exe_path();
  for (int i = 1; i < *argc; i++) {
    added[i + 1] = (*argv)[i];
  }
  (*argc)++;
  *argv = added;
}

int main(int argc, char **argv) {
  // Use the standard library .zip concatenated onto our own executable image.
  setenv("PYTHONHOME", self_exe_path(), 1);

  // Keep the environment below in sync with //bazel/python:_repo_python3.*.bash

#ifdef __linux__
  // Make Backspace work.
  // See:
  // https://python-build-standalone.readthedocs.io/en/latest/quirks.html#backscape-key-doesn-t-work-in-python-repl
  setenv("TERMINFO_DIRS", "/etc/terminfo:/lib/terminfo:/usr/share/terminfo", 0);
#endif  // __linux__

#ifdef GRAIL_PYTHON_EXEC_SELF_ZIP
  // Add path to this exe (Python + .zip) as the first argument so the Python
  // interpreter executes our zip.
  add_self_exec_argv(&argc, &argv);
#endif  // GRAIL_PYTHON_EXEC_SELF_ZIP

  // TODO: Ideally, we should make sure sibling files (lib/python3*, etc.)
  // aren't on the import path so that program execution won't change based on
  // what's around in the filesystem.
  return _Py_UnixMain(argc, argv);
}
