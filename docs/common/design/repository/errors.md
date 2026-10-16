# 공통 에러 코드

Oct 6, 2026 · @DevYoung

Repository 쓰기 메서드의 반환 모양(`Result`)과 에러 코드만 다룬다. 상황별 안내 문구는 [policy.md](../../planning/policy.md#오류-안내)가 정의한다.

## 반환 모양

Repository의 쓰기 메서드([orders.md](./orders.md#메서드))와 그 안의 규칙 함수는 예외를 던지지 않고 `Result`를 반환한다. 서버 API의 공통 응답 형식에 해당한다.

```ts
type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: { code: ErrorCode; message: string } };
```

실패 예시:

```
{ ok: false, error: { code: "OUT_OF_STOCK", message: "재고가 부족합니다." } }
```

- `code`: 화면 분기와 테스트 판별에 쓴다
- `message`: 사용자에게 보여줄 안내 문구다. policy.md 오류 안내 표의 문구를 그대로 쓴다
- `OrderContext` 액션이 `message`를 전역 토스트에 그대로 표시한다([context](../context/README.md#액션-공통-흐름)). 단, `COUPON_NOT_APPLICABLE`·`MIN_AMOUNT_NOT_MET`는 토스트를 띄우지 않고 기존 선택을 유지한다

## 코드

| code | 상황(policy.md 오류 안내) |
| --- | --- |
| EMPTY_CART | 체크한 품목 없이 주문 |
| INVALID_QUANTITY | 수량이 1~99 밖 |
| OUT_OF_STOCK | 재고보다 많은 수량 주문 |
| COUPON_NOT_APPLICABLE | 사용 조건을 충족하지 않는 쿠폰 적용 |
| MIN_AMOUNT_NOT_MET | 최소 주문금액에 못 미치는 쿠폰 적용 |
| INVALID_TRANSITION | 현재 주문 상태에서 할 수 없는 동작 |

## 주문 없음

존재하지 않는 주문 id는 에러 코드가 아니다. `getOrder(id)`가 `null`을 반환하면 호출부(페이지 진입 판정, [routing.md](../ui/routing.md#진입-판정))가 404 화면으로 분기한다.
