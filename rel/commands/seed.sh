#!/bin/sh

release_ctl eval --mfa "Bookclub.ReleaseTasks.seed/1" --argv -- "$@"
