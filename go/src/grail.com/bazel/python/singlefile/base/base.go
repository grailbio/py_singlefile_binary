package main

import (
	"archive/zip"
	"bytes"
	_ "embed"
	"io"
	"io/fs"
	"log"
	"os"
	"path"
	"strings"
	"syscall"

	"github.com/grailbio/base/must"
	"github.com/grailbio/base/traverse"
)

// diskCacheName names the subdirectory within the user's cache directory where we'll extract.
const diskCacheName = "grail_py_singlefile"

const (
	// appDir is an arbitrary name we choose to contain the extracted application.
	appDir = "app"
	// runfilesDir names where we will extract runfiles, so that Bazel's Python bootstrap works.
	// Bazel's Python zipper places a runfiles/ directory in the .zip and locates it after extraction:
	// https://github.com/bazelbuild/bazel/blob/5.3.0/src/main/java/com/google/devtools/build/lib/bazel/rules/python/python_stub_template.txt#L155
	// However, since we're extracting ourselves (abusing the Bazel .zip format somewhat), we move the
	// runfiles directory to where __main__.py will find it:
	// https://github.com/bazelbuild/bazel/blob/5.3.0/src/main/java/com/google/devtools/build/lib/bazel/rules/python/python_stub_template.txt#L105
	runfilesDir = appDir + ".runfiles"
)

// pythonBinName and zipCacheFile are set at link time.
var pythonBinName, zipCacheFile string

func main() {
	if pythonBinName == "" || zipCacheFile == "" {
		log.Fatalf("missing constants from build/link time (must be built with bazel)")
	}
	selfPath, err := os.Executable()
	if err != nil {
		log.Fatalf("python/singlefile/base: locating self: %v", err)
	}
	selfZip, err := zip.OpenReader(selfPath)
	if err != nil {
		log.Fatalf("python/singlefile/base: opening self as zip %s: %v", selfPath, err)
	}
	cacheKey, err := fs.ReadFile(selfZip, zipCacheFile)
	if err != nil {
		log.Fatalf("python/singlefile/base: reading cache key: %v", err)
	}
	xDir, err := extractPythonDir(string(cacheKey), &selfZip.Reader)
	if err != nil {
		log.Fatalf("python/singlefile/base: extracting python binary: %v", err)
	}
	if err = selfZip.Close(); err != nil {
		log.Fatalf("python/singlefile/base: closing self zip: %v", err)
	}
	pyExePath := path.Join(xDir, runfilesDir, pythonBinName)
	argv := append([]string{pyExePath, path.Join(xDir, appDir)}, os.Args[1:]...)
	must.Nil(syscall.Exec(pyExePath, argv, os.Environ()))
}

func extractPythonDir(cacheKey string, zr *zip.Reader) (string, error) {
	var userCacheDir string
	var err error
	if os.Getenv("HOME") == "" && os.Getenv("TEST_TMPDIR") != "" {
		// Special case for bazel tests, in which HOME is not set.
		// Bazel documentation recommends HOME be set in the test environment, but it's not set as of our current version.
		//   http://web.archive.org/web/20191210225819/https://docs.bazel.build/versions/master/test-encyclopedia.html#initial-conditions
		userCacheDir = os.Getenv("TEST_TMPDIR")
	} else {
		userCacheDir, err = os.UserCacheDir()
		if err != nil {
			return "", err
		}
	}

	cacheDir := path.Join(userCacheDir, diskCacheName)
	if err := os.MkdirAll(cacheDir, 0700); err != nil {
		return "", err
	}

	itemDir := path.Join(cacheDir, cacheKey)
	if _, err := os.Stat(itemDir); err == nil {
		return itemDir, nil
	}

	itemTmpDir, err := os.MkdirTemp(cacheDir, "."+cacheKey+".*")
	if err != nil {
		return "", err
	}
	defer func() { _ = os.RemoveAll(itemTmpDir) }()

	err = traverse.Parallel.Each(len(zr.File), func(fileIdx int) error {
		zf := zr.File[fileIdx]
		dstName := path.Join(itemTmpDir, appDir, zf.Name)
		if strings.HasPrefix(zf.Name, "runfiles/") {
			// See appDir.
			dstName = path.Join(itemTmpDir, runfilesDir, zf.Name[len("runfiles/"):])
		}
		if err = os.MkdirAll(path.Dir(dstName), 0700); err != nil {
			return err
		}
		f, err := os.OpenFile(dstName, os.O_CREATE|os.O_WRONLY, zf.Mode())
		if err != nil {
			return err
		}
		zfc, err := zf.Open()
		if err != nil {
			return err
		}
		if zf.Name == "__main__.py" {
			content, err := io.ReadAll(zfc)
			if err != nil {
				return err
			}
			// See appDir.
			content = bytes.Replace(content,
				[]byte("def IsRunningFromZip():\n  return True\n"),
				[]byte("def IsRunningFromZip():\n  return False\n"),
				1)
			if _, err = f.Write(content); err != nil {
				return err
			}
		} else {
			if _, err = io.Copy(f, zfc); err != nil {
				return err
			}
		}
		if err = zfc.Close(); err != nil {
			return err
		}
		if err = f.Close(); err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		return "", err
	}

	if err = os.Rename(itemTmpDir, itemDir); err != nil {
		if _, errStat := os.Stat(itemDir); errStat != nil {
			return "", err
		}
		// Looks like a concurrent process extracted the same thing. Fall through.
	}
	return itemDir, nil
}
