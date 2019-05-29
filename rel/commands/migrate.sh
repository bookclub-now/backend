#!/bin/sh

release_ctl eval --mfa "Bookclub.ReleaseTasks.migrate/1" --argv -- "$@"

