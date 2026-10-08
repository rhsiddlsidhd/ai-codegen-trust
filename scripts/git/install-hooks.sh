#!/bin/sh
# clone마다 한 번 실행해 scripts/git의 hook을 활성화한다.

cd "$(git rev-parse --show-toplevel)" || exit 1

git config core.hooksPath scripts/git
chmod +x scripts/git/pre-commit scripts/git/commit-msg

echo "core.hooksPath=$(git config --get core.hooksPath)"
