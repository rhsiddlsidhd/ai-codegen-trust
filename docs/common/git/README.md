# Git (프로젝트 전용)

Oct 7, 2026 · @DevYoung

이 디렉토리는 이 repo가 `guarded/`, `unguarded/`, `docs/common/`을 단일 git으로 관리하면서 필요한 **추가 규칙**만 다룬다. 겹치지 않는 항목(브랜치 베이스 정책, force-push 금지, PR 머지 방식 등)은 글로벌 규칙(`~/.codex/docs/GIT.md`) 그대로 따른다.

## 배경

이 repo는 가드레일 유무만 다른 두 프로젝트(`guarded/`, `unguarded/`)와 그 둘이 공유하는 `docs/common/`을 한 저장소로 관리한다. 여러 에이전트가 각자 워크트리에서 자기 경로만 건드려 작업하는데, 그 결과(브랜치/커밋/PR)가 **열어보기 전에** 어느 경로 작업인지 구분돼야 한다. 이 디렉토리의 규칙은 전부 그 구분을 위한 scope 토큰 하나로 통일된다.

## 목차

- [branch.md](./branch.md) — 브랜치 네이밍
- [commit.md](./commit.md) — 커밋 메시지
- [pr.md](./pr.md) — PR 제목
- [worktree.md](./worktree.md) — 워크트리 scope 경계

## Scope 토큰

다른 파일은 코드만 참조하고, 설명은 여기서만 관리한다.

| 토큰 | 범위 |
| --- | --- |
| `guarded` | `guarded/` 안의 변경 |
| `unguarded` | `unguarded/` 안의 변경 |
| `docs` | `docs/common/` 안의 변경 |
| `root` | 위 셋에 안 들어가는 루트 파일(`README.md`, `AGENTS.md` 등) 변경 |

한 커밋/브랜치/PR은 scope 토큰 하나에만 대응해야 한다 — 두 프로젝트 경로를 섞지 않는다.
