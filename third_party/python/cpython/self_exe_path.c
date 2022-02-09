#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __linux__
#include <unistd.h>

char *self_exe_path() {
  const size_t MAX_LEN = 2048;
  char *path = (char *)malloc(MAX_LEN);
  if (path == NULL) {
    fprintf(stderr, "error from malloc\n");
    abort();
  }
  ssize_t result = readlink("/proc/self/exe", path, MAX_LEN);
  if (result < 0) {
    fprintf(stderr, "error from readlink: %d\n", errno);
    abort();
  }
  if ((size_t)result == MAX_LEN) {
    fprintf(stderr, "readlink returned max path len: %d\n", (int)result);
    abort();
  }
  path[result] = '\0';
  return path;
}
#endif  // __linux__

#ifdef __APPLE__
#include <mach-o/dyld.h>

char *self_exe_path() {
  uint32_t path_len = 0;
  _NSGetExecutablePath(NULL, &path_len);
  char *path = (char *)malloc(path_len + 1);
  if (path == NULL) {
    fprintf(stderr, "error from malloc\n");
    abort();
  }
  int result = _NSGetExecutablePath(path, &path_len);
  if (result != 0) {
    fprintf(stderr, "error from _NSGetExecutablePath: %d\n", result);
    abort();
  }
  path[path_len] = '\0';
  return path;
}
#endif  // __APPLE__
