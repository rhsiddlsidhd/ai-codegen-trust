# 컴포넌트 규칙

Oct 6, 2026 · @DevYoung

재사용 컴포넌트를 어떻게 만드는지 규칙만 다룬다. 구체적으로 뭘 만들지는 구현 단계에서 정한다. 배치는 [wireframe.md](./wireframe.md), 데이터는 [docs/common/repository/](../repository/)를 따른다.

## 원자 컴포넌트

UI 원자 컴포넌트는 shadcn/ui만 쓴다. 직접 만든 커스텀 원자 컴포넌트는 없다.

## 합성 규칙

재사용이 필요한 컴포넌트는 shadcn/ui 부품을 조합해서 만든다. 새 원자를 만드는 대신 기존 shadcn/ui 부품을 합성하는 선택지가 항상 먼저다.

## 위치

```
src/components/
  ui/              # shadcn CLI로 설치한 원자 컴포넌트(button.tsx, input.tsx, tabs.tsx, ...), 직접 수정 안 함
  CartItem/        # ui/ 부품을 조합한 재사용 컴포넌트(예시), 컴포넌트당 폴더 하나
    CartItem.tsx   # 구현
    index.ts       # re-export 전용 barrel
```

`ui/`는 shadcn CLI 산출물 전용이라 손으로 안 고친다. 합성 컴포넌트는 `components/` 아래 PascalCase 폴더(위 `CartItem`은 예시) 하나씩으로 두고, 폴더 안에 구현 파일(`{컴포넌트명}.tsx`)과 그걸 re-export만 하는 `index.ts`를 둔다. 컴포넌트 하나당 폴더 하나다.

## 전역 요소 중복 금지

라우트마다 반복되는 요소(에러 토스트, 보유 현금 표시 등)는 라우트별로 각각 구현하지 않고, 전역 레이아웃/전역 컴포넌트 하나로 통일해서 모든 라우트가 공유한다.
