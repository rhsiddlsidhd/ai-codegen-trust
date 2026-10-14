# 도메인

Oct 14, 2026 · @DevYoung

비즈니스 규칙을 코드로 옮긴 순수 함수만 다룬다. 저장소와 화면은 모르고, 입력을 받아 `Result`만 반환한다. 규칙은 [policy.md](../../planning/policy.md), 타입은 [design/repository/](../repository/), 저장·조율은 [design/context/](../context/)를 따른다.

## 목차

- [위치](#위치)
- [Result](#result)
- [상태 전이](#상태-전이)
- [함수 계약](#함수-계약)
- [쿠폰 실패 코드](#쿠폰-실패-코드)
- [결과 예시](#결과-예시)

## 위치

`src/domain/{topic}/`에 두고 `src/domain/index.ts`가 재노출한다([structure.md](../architecture/structure.md)).

## Result

```ts
type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: { code: ErrorCode; message: string } };
```

실패 모양과 code 목록은 [errors.md](../repository/errors.md)를 따른다.

## 상태 전이

| status | 표시명([policy.md](../../planning/policy.md#주문-상태)) |
| --- | --- |
| CREATED | 결제 대기 |
| PAID | 결제 완료 |
| PAYMENT_FAILED | 결제 실패 |
| CANCELED | 주문 취소 |
| REFUNDED | 환불 완료 |

| 현재 \ 함수 | applyCoupon, removeCoupon | pay | cancel | refund |
| --- | --- | --- | --- | --- |
| CREATED | CREATED | PAID 또는 PAYMENT_FAILED | CANCELED | ✗ |
| PAID | ✗ | ✗ | ✗ | REFUNDED |
| PAYMENT_FAILED, CANCELED, REFUNDED | ✗ | ✗ | ✗ | ✗ |

- ✗는 `INVALID_TRANSITION`
- `createOrder`는 장바구니(저장되지 않는 시작점)에서 CREATED를 만든다

## 함수 계약

| 함수 | 입력 | 성공 `value` | 실패 code (검사 순서대로) |
| --- | --- | --- | --- |
| `createOrder` | `lines: {productId, qty}[]`(체크한 품목만), `products: Product[]`, `orderId: string` | `{ order, stock }` | EMPTY_CART → INVALID_QUANTITY → OUT_OF_STOCK |
| `evaluateCoupon` | `coupon: Coupon`, `order: Order` | `{ discount, payable }` | COUPON_NOT_APPLICABLE, MIN_AMOUNT_NOT_MET |
| `applyCoupon` | `order: Order`, `coupon: Coupon` | `Order` | INVALID_TRANSITION → `evaluateCoupon`의 실패 code |
| `removeCoupon` | `order: Order` | `Order` | INVALID_TRANSITION |
| `pay` | `order: Order`, `wallet: Wallet`, `stock: StockMap` | `{ order, wallet, stock }` | INVALID_TRANSITION |
| `cancel` | `order: Order`, `stock: StockMap` | `{ order, stock }` | INVALID_TRANSITION |
| `refund` | `order: Order`, `wallet: Wallet`, `stock: StockMap` | `{ order, wallet, stock }` | INVALID_TRANSITION |

- `orderId`는 밖에서 받는다. 도메인 안에서 `crypto.randomUUID()`를 부르면 결과가 매번 달라 테스트 기대값을 고정할 수 없다
- `createOrder`가 만드는 주문은 쿠폰 미적용 상태다 — `couponCode`/`failureReason`은 null, `discount`는 0, `payable`은 `subtotal`과 같다
- `evaluateCoupon`은 /payment의 사용 가능/불가 분류(`ok`면 사용 가능)와 `applyCoupon` 내부 검사에 같이 쓴다. 할인 계산식은 [coupons.md](../repository/coupons.md#할인-계산)를 따른다
- `applyCoupon`은 `couponCode`/`discount`/`payable`만 바꾸고 `subtotal`은 그대로 둔다. `removeCoupon`은 `couponCode`를 null, `discount`를 0, `payable`을 `subtotal`로 되돌린다
- `pay`: `wallet.cash >= order.payable`이면 PAID(`cash` 차감), 아니면 PAYMENT_FAILED(`failureReason` 설정, 재고 복원). 둘 다 `ok: true`다
- `cancel`·`refund`는 재고를 품목 수량만큼 복원하고, `refund`는 `payable`만큼 `cash`도 복원한다. 둘 다 `couponCode`/`discount`/`payable`은 그대로 둔다

## 쿠폰 실패 코드

| 쿠폰 종류 | type | 실패 상황 | code |
| --- | --- | --- | --- |
| 대상 상품 쿠폰 | C1 | 대상 상품이 주문에 없음 | COUPON_NOT_APPLICABLE |
| 고액 라인 쿠폰 | C2 | 기준 이상 라인이 없음 | COUPON_NOT_APPLICABLE |
| 최소 주문금액 쿠폰 | C3 | `subtotal < minOrderAmount` | MIN_AMOUNT_NOT_MET |
| 전체 주문 쿠폰 | C4 | 없음 | — |

## 결과 예시

성공 시 `value.order`의 예시다.

### `createOrder`

```json
{
  "orderId": "3f2b8c1e-9a4d-4e7b-8c2a-1d5e6f7a8b9c",
  "status": "CREATED",
  "items": [{ "productId": "P1", "title": "상품 P1", "price": 3000, "qty": 2 }],
  "subtotal": 6000,
  "couponCode": null,
  "discount": 0,
  "payable": 6000,
  "failureReason": null
}
```

### `applyCoupon`

```json
{
  "orderId": "3f2b8c1e-9a4d-4e7b-8c2a-1d5e6f7a8b9c",
  "status": "CREATED",
  "items": [{ "productId": "P2", "title": "상품 P2", "price": 10000, "qty": 1 }],
  "subtotal": 10000,
  "couponCode": "ORDER_5000",
  "discount": 5000,
  "payable": 5000,
  "failureReason": null
}
```

### `pay (PAYMENT_FAILED)`

```json
{
  "orderId": "3f2b8c1e-9a4d-4e7b-8c2a-1d5e6f7a8b9c",
  "status": "PAYMENT_FAILED",
  "items": [{ "productId": "P2", "title": "상품 P2", "price": 10000, "qty": 1 }],
  "subtotal": 10000,
  "couponCode": null,
  "discount": 0,
  "payable": 10000,
  "failureReason": { "code": "INSUFFICIENT_CASH", "message": "현금이 부족합니다." }
}
```

### `cancel`

```json
{
  "orderId": "3f2b8c1e-9a4d-4e7b-8c2a-1d5e6f7a8b9c",
  "status": "CANCELED",
  "items": [{ "productId": "P1", "title": "상품 P1", "price": 3000, "qty": 2 }],
  "subtotal": 6000,
  "couponCode": null,
  "discount": 0,
  "payable": 6000,
  "failureReason": null
}
```

### `refund`

```json
{
  "orderId": "3f2b8c1e-9a4d-4e7b-8c2a-1d5e6f7a8b9c",
  "status": "REFUNDED",
  "items": [{ "productId": "P2", "title": "상품 P2", "price": 10000, "qty": 1 }],
  "subtotal": 10000,
  "couponCode": "ORDER_5000",
  "discount": 5000,
  "payable": 5000,
  "failureReason": null
}
```
