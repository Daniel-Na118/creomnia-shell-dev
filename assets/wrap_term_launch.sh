#!/usr/bin/env sh

cat ~/.local/state/creomnia/sequences.txt 2>/dev/null

exec "$@"
