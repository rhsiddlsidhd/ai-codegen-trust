# 커밋 메시지

Oct 7, 2026 · @DevYoung

scope 토큰은 [README.md](./README.md)를 따른다. 그 외 커밋 정책(`add -A` 금지, `--no-verify` 금지, 기존 커밋 재작성 금지 등)은 글로벌 `~/.codex/docs/GIT.md`의 Commit 섹션을 따른다.

## 규칙

글로벌 포맷 `{prefix}({scope}): {message}`의 scope 자리에 scope 토큰을 쓴다.

```
{prefix}({scope}): {message}
```

| 예시 |
| --- |
| `feat(guarded): add cart page` |
| `fix(unguarded): coupon calc off-by-one` |
| `docs(docs): update wireframe` |

메시지 본문 규칙(소문자 시작 영어 동사 원형, 마침표 없음, 72자 이내)은 글로벌 규칙 그대로.
