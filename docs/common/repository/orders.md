# 주문 레포지토리

Oct 6, 2026 · @DevYoung

주문 생성·조회·쿠폰 적용·결제·취소·환불만 다룬다. 상품은 [products.md](./products.md), 쿠폰은 [coupons.md](./coupons.md), 지갑은 [wallet.md](./wallet.md), 에러 코드는 [errors.md](./errors.md)를 따른다.

## 타입

필드만 고정한다.

**Order**

| 필드 | 타입 | 예시 | 설명 |
| --- | --- | --- | --- |
| orderId | string | `"o_123"` | 주문 id. 주문 생성 시 클라이언트에서 `crypto.randomUUID()`로 발급(네이티브 API, 별도 의존성 없음). 이후 `saveOrder`/`getOrder`가 이 값을 키로 저장·조회한다 |
| status | string | `"PAID"` | 상태 코드명(CREATED/PAID/PAYMENT_FAILED/CANCELED/REFUNDED) |
| items | OrderItem[] | - | 주문 품목 |
| subtotal | number | `10000` | 할인 전 금액(items의 price×qty 합, "주문금액") |
| couponCode | string \| null | `"ORDER_5000"` | 적용된 쿠폰 코드, 없으면 null |
| discount | number | `5000` | 할인액 |
| payable | number | `9500` | 최종 결제금액(subtotal - discount) |
| failureReason | `{code, message}` \| null | `null` | 결제 실패 이유. PAYMENT_FAILED가 아니면 null (코드는 현재 INSUFFICIENT_CASH 하나) |

**OrderItem**

주문 생성 시점의 `title`/`price`를 스냅샷으로 저장한다(나중에 Product 가격이 바뀌어도 영수증은 그때 값을 유지). `/payment/:id`·`/orders/:id`가 상품 목록을 보여줄 때 `getProducts()`를 다시 조회할 필요 없다.

| 필드 | 타입 | 예시 | 설명 |
| --- | --- | --- | --- |
| productId | string | `"P1"` | 상품 id |
| title | string | `"상품 P1"` | 주문 시점 상품명 |
| price | number | `3000` | 주문 시점 단가(원) |
| qty | number | `2` | 수량(1~99) |

## 함수

| 함수 | 시그니처 | 설명 |
| --- | --- | --- |
| getOrder | `(orderId: string): Order \| null` | sessionStorage에서 주문 하나를 조회한다. 없으면 `null` — 호출부(페이지 가드)가 404 화면으로 분기한다. `ORDER_NOT_FOUND`는 도메인 에러 코드가 아니라 이 null 체크다([errors.md](./errors.md)) |
| saveOrder | `(order: Order): void` | 주문을 sessionStorage에 생성/갱신(upsert)한다 |

## 동작별 처리 흐름

각 동작은 레포지토리에서 현재 상태를 읽고, 계산한 결과를 다시 레포지토리에 써서 끝난다. 네트워크 호출 없이 전부 클라이언트 안에서 동기적으로 일어난다.

### 주문 생성 (CART → CREATED)

쿠폰 미포함(쿠폰은 생성 후 아래 "쿠폰 선택/교체"로 적용). 에러: EMPTY_CART, INVALID_QUANTITY, OUT_OF_STOCK.

1. `getProducts()`로 현재 `StockMap` 확보
2. `crypto.randomUUID()`로 `orderId` 발급, 장바구니 items로 주문 구성
3. 실패(`ok:false`)면 에러코드만 전달, `saveOrder`/`updateStock` 안 함(상태 변화 없음)
4. 성공하면 `saveOrder(order)` + `updateStock(stock)`

쿠폰 미선택 상태라 `couponCode`/`failureReason`은 null, `discount`는 0, `payable`은 `subtotal`과 같다.

```json
{
  "orderId": "o_123",
  "status": "CREATED",
  "items": [{ "productId": "P1", "title": "상품 P1", "price": 3000, "qty": 2 }],
  "subtotal": 6000,
  "couponCode": null,
  "discount": 0,
  "payable": 6000,
  "failureReason": null
}
```

### 쿠폰 선택/교체 (CREATED 상태에서만)

에러: ORDER_NOT_FOUND, INVALID_TRANSITION, COUPON_NOT_APPLICABLE, MIN_AMOUNT_NOT_MET.

1. `getOrder(orderId)`로 현재 주문 확보(없으면 404)
2. 선택한 쿠폰으로 할인액·결제금액을 계산한다 — `coupon`은 `getCoupons()` 목록 중 화면에서 선택한 것([coupons.md](./coupons.md))
3. 실패면 에러코드만 전달, 기존 선택 유지 — `saveOrder` 안 함
4. 성공하면 `order.couponCode`/`discount`/`payable`을 갈아끼우고 `saveOrder(order)`. `subtotal`은 그대로

```json
{
  "orderId": "o_123",
  "status": "CREATED",
  "items": [{ "productId": "P2", "title": "상품 P2", "price": 10000, "qty": 1 }],
  "subtotal": 10000,
  "couponCode": "ORDER_5000",
  "discount": 5000,
  "payable": 5000,
  "failureReason": null
}
```

### 결제 시도 (CREATED → PAID | PAYMENT_FAILED)

결제 수단 선택 없음 — 지갑 현금과 `payable`을 비교해 성공/실패를 결정한다. 에러: ORDER_NOT_FOUND, INVALID_TRANSITION. PAID/PAYMENT_FAILED는 둘 다 정상 결과이지 에러가 아니다.

1. `getOrder(orderId)` + `getWallet()`
2. 지갑 현금과 `payable`을 비교해 PAID/PAYMENT_FAILED를 결정한다
3. `saveOrder(order)`. 성공(PAID)이면 `saveWallet(wallet)`도 호출(차감 반영) — 실패(PAYMENT_FAILED)면 지갑 변화 없어서 안 해도 됨

```json
{
  "orderId": "o_123",
  "status": "PAYMENT_FAILED",
  "items": [{ "productId": "P2", "title": "상품 P2", "price": 10000, "qty": 1 }],
  "subtotal": 10000,
  "couponCode": null,
  "discount": 0,
  "payable": 10000,
  "failureReason": { "code": "INSUFFICIENT_CASH", "message": "현금이 부족합니다" }
}
```

### 취소 (CREATED → CANCELED)

사용자 취소. 에러: ORDER_NOT_FOUND, INVALID_TRANSITION.

1. `getOrder(orderId)` + `getProducts()`
2. 재고를 품목 수량만큼 복원
3. `saveOrder(order)` + `updateStock(stock)`. 지갑 현금은 변화 없다(차감한 적이 없어서)

```json
{
  "orderId": "o_123",
  "status": "CANCELED",
  "items": [{ "productId": "P1", "title": "상품 P1", "price": 3000, "qty": 2 }],
  "subtotal": 6000,
  "couponCode": null,
  "discount": 0,
  "payable": 6000,
  "failureReason": null
}
```

### 환불 (PAID → REFUNDED)

전체 환불, 결제한 금액 전액. 에러: ORDER_NOT_FOUND, INVALID_TRANSITION.

1. `getOrder(orderId)` + `getProducts()` + `getWallet()`
2. 재고 복원, 결제 때 차감한 현금 복원
3. `saveOrder(order)` + `updateStock(stock)` + `saveWallet(wallet)`

```json
{
  "orderId": "o_123",
  "status": "REFUNDED",
  "items": [{ "productId": "P2", "title": "상품 P2", "price": 10000, "qty": 1 }],
  "subtotal": 10000,
  "couponCode": "ORDER_5000",
  "discount": 5000,
  "payable": 5000,
  "failureReason": null
}
```
