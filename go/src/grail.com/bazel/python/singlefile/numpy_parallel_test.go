package singlefile_test

import (
	"os/exec"
	"testing"

	"github.com/bazelbuild/rules_go/go/tools/bazel"
	"github.com/grailbio/base/traverse"
	"github.com/stretchr/testify/require"
)

func TestParallel(t *testing.T) {
	exe, err := bazel.Runfile("bazel/python/singlefile/numpy_bin")
	require.NoError(t, err)
	require.NoError(t, traverse.Each(8, func(int) error {
		_, err := exec.Command(exe).Output()
		return err
	}))
}
