#!/bin/sh
# PR의 각 커밋과 제목이 scope 규칙을 지키는지 검사한다. 로컬 hook을 우회한 커밋도 여기서 걸린다.
# 사용: check-commit-scopes.sh <base-sha> <head-sha> [<pr-title>]

. "$(dirname "$0")/../common/scope.sh"

base=$1
head=$2
title=$3
fail=0

fail_with() {
  echo "$1" >&2
  fail=1
}

pr_scope=""
if [ -n "$title" ]; then
  pr_scope=$(message_scope "$title")
  if ! is_scope "$pr_scope"; then
    fail_with "PR 제목에 올바른 scope가 없다: $title"
    pr_scope=""
  fi
fi

for sha in $(git rev-list --no-merges "$base..$head"); do
  short=$(git rev-parse --short "$sha")
  subject=$(git log -1 --format=%s "$sha")
  msg_scope=$(message_scope "$subject")

  if ! is_scope "$msg_scope"; then
    fail_with "$short: 커밋 메시지에 올바른 scope가 없다: $subject"
    continue
  fi

  actual=$(git diff-tree --no-commit-id --name-only -r --no-renames "$sha" | while IFS= read -r path; do
    scope_of "$path"
  done | sort -u)

  if [ -n "$actual" ] && [ "$actual" != "$msg_scope" ]; then
    fail_with "$short: 메시지 scope는 '$msg_scope'인데 변경 경로의 scope는 '$(printf '%s' "$actual" | tr '\n' ' ')'이다: $subject"
  fi

  if [ -n "$pr_scope" ] && [ "$pr_scope" != "$msg_scope" ]; then
    fail_with "$short: PR 제목 scope '$pr_scope'와 커밋 scope '$msg_scope'가 다르다: $subject"
  fi
done

exit "$fail"
