# 브랜치 네이밍

Oct 7, 2026 · @DevYoung

scope 토큰은 [README.md](./README.md)를 따른다. 그 외 브랜치 정책(베이스 브랜치, force-push 금지 등)은 글로벌 `~/.codex/docs/GIT.md`의 Branch 섹션을 따른다.

## 규칙

글로벌 포맷 `{prefix}/{kebab-case}`에 scope 토큰을 kebab-case 슬러그 맨 앞에 붙인다.

```
{prefix}/{scope}-{kebab-case}
```

prefix(`feat/fix/docs/refactor/perf/test/build/ci/chore/revert`) 선택 기준은 글로벌 규칙 그대로.

| 예시 | 의미 |
| --- | --- |
| `feat/guarded-cart-page` | guarded 프로젝트에 장바구니 페이지 추가 |
| `fix/unguarded-coupon-calc` | unguarded 프로젝트 쿠폰 계산 버그 수정 |
| `docs/docs-wireframe-update` | 공통 와이어프레임 문서 수정 |
