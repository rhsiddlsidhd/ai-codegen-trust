# 기술 스택과 아키텍처 제약

Oct 5, 2026 · @DevYoung

두 군이 같은 기술적 제약 위에서 구현해야, 결과 차이가 가드레일 때문인지 기술 선택 때문인지가 섞이지 않는다. 노출 계약은 [design/repository/](../repository/), 컴포넌트 규칙은 [ui/components.md](../ui/components.md)를 따른다.

## 기술 스택

정확한 버전은 각 프로젝트의 `package.json`과 lockfile이 기준이다. 아래는 major 버전만 적는다.

| 항목 | 도구 | major |
| --- | --- | --- |
| 프레임워크 | Vite + React | Vite 8, React 19 |
| 라우팅 | React Router | 7 |
| 언어 | TypeScript | 6 |
| 스타일링 | Tailwind CSS | 3 |
| UI 컴포넌트 | shadcn/ui (new-york) | — |
| 아이콘 | lucide-react | 1 |
| 토스트 | sonner (shadcn) | — |
| 전역 상태 관리 | React Context | — |
| 테스트 (guarded만) | Vitest, React Testing Library, Playwright | Vitest 5, RTL 16, Playwright 1 |
| 린트/포맷 | ESLint, Prettier | ESLint 10, Prettier 3 |

테스트 도구는 guarded에만 둔다. unguarded는 테스트 없이 구현하는 비교군이다.

## 로컬 저장소

| 항목 | 도구 |
| --- | --- |
| 브라우저 저장소 | sessionStorage |

