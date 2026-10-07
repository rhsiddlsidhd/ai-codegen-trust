# 워크트리 scope 경계

Oct 7, 2026 · @DevYoung

워크트리 디렉토리명 도출(브랜치명의 `/`를 `-`로) 등 기본 정책은 글로벌 `~/.codex/docs/GIT.md`의 Worktree 섹션을 따른다. 여기서는 scope 경계만 추가로 다룬다.

## 규칙

에이전트는 자기 워크트리의 scope 경로 밖 파일을 건드리지 않는다. 작업 중 다른 scope(예: guarded 작업하다 `docs/common` 수정 필요)를 건드려야 하면, 그 변경은 별도 scope로 분리해 별도 브랜치·커밋·PR로 낸다.
