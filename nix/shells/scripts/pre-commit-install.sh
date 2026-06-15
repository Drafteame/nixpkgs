#!/usr/bin/env bash
# Install pre-commit + commit-msg hooks on entry to the dev shell.
# Idempotent: pre-commit re-points the hook scripts on every run, so it's
# safe to source from a shellHook. Silenced on success.

if [ -d .git ] && command -v pre-commit >/dev/null 2>&1; then
  pre-commit install \
    --hook-type pre-commit \
    --hook-type commit-msg \
    >/dev/null 2>&1 || true
fi
