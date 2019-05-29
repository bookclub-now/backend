#!/usr/bin/env bash

if [ "$K8S_ENV" = "staging" ]; then
    /app/bin/bookclub migrate
fi

