# 경로 → scope 라벨 판정. docs/common/git/README.md의 scope 토큰 표와 같은 규칙이다.
# 다른 스크립트에서 `. scope.sh`로 불러 쓰는 파일이라 직접 실행하지 않는다.

# 경로 하나를 받아 scope 라벨을 출력한다.
scope_of() {
  case "$1" in
    guarded/*)   echo guarded ;;
    unguarded/*) echo unguarded ;;
    docs/*)      echo docs ;;
    *)           echo root ;;
  esac
}

# 커밋/PR 제목에서 scope를 출력한다. 형식이 맞지 않으면 아무것도 출력하지 않는다.
message_scope() {
  printf '%s' "$1" | sed -nE 's/^[a-z]+\(([^)]*)\)!?: .*/\1/p'
}

# scope 라벨이면 성공(0)을 반환한다.
is_scope() {
  case "$1" in
    guarded|unguarded|docs|root) return 0 ;;
    *) return 1 ;;
  esac
}

# 스테이징된 경로를 "<scope> <경로>" 한 줄씩 출력한다. 이름 변경은 옛 경로와 새 경로를 모두 나열한다.
staged_paths_with_scope() {
  git diff --cached --name-only --no-renames | while IFS= read -r path; do
    printf '%s %s\n' "$(scope_of "$path")" "$path"
  done
}

# 스테이징된 경로의 scope 라벨을 중복 없이 한 줄씩 출력한다.
staged_scopes() {
  staged_paths_with_scope | cut -d' ' -f1 | sort -u
}
