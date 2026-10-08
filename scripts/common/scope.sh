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
