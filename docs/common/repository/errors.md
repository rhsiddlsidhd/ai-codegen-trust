# 공통 에러 코드

Oct 6, 2026 · @DevYoung

도메인별 명세([products.md](./products.md), [coupons.md](./coupons.md), [orders.md](./orders.md))는 코드만 참조하고, 설명은 여기서만 관리한다.

## 반환 모양

도메인 모듈(`src/domain/index.ts`)은 규칙 위반을 만나면 예외를 던지지 않고 아래 모양으로 반환한다.

```
{ ok: false, error: "OUT_OF_STOCK" }
```

도메인 함수는 `error`(code)만 반환하고 `message`는 모른다 — message는 이 표를 보고 호출부(에러를 받아 화면에 표시하는 쪽, 전역 토스트)가 붙인다. 화면은 `error`로 분기하고 `message`는 로그·디버깅용으로만 쓴다(쿠폰 관련 코드는 사유 자체를 화면에 안 보여줌).

## 코드와 메시지

| code | message |
| --- | --- |
| EMPTY_CART | 품목 0개로 주문 생성 시도 |
| INVALID_QUANTITY | 수량이 1~99 범위 밖 |
| OUT_OF_STOCK | 재고보다 많은 수량 주문 |
| COUPON_NOT_APPLICABLE | 대상 라인이 없거나 선택 불가한 쿠폰 적용 시도 |
| MIN_AMOUNT_NOT_MET | 쿠폰의 최소 주문금액 미달 |
| INVALID_TRANSITION | 상태 전이표에 없는 전이 시도 |
| ORDER_NOT_FOUND | 존재하지 않는 주문 id로 조회·조작 시도 (레포지토리 계약 차원, 도메인 규칙 아님. `getOrder(id)`가 `null` 반환 — 호출부가 404 화면으로 분기하지, 도메인 함수가 이 코드를 반환하는 게 아니다) |
