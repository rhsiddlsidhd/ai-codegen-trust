# 주문 레포지토리

Oct 6, 2026 · @DevYoung

주문 타입, 주문 동작 메서드, 그 안에서 쓰는 규칙 함수만 다룬다. 규칙의 근거는 [policy.md](../../planning/policy.md), 메서드를 호출하는 쪽 흐름은 [design/context/](../context/)를 따른다. 상품은 [products.md](./products.md), 쿠폰은 [coupons.md](./coupons.md), 지갑은 [wallet.md](./wallet.md), 반환 모양과 에러 코드는 [errors.md](./errors.md)를 따른다.

## 목차

- [타입](#타입)
- [메서드](#메서드)
- [메서드 내부 처리](#메서드-내부-처리)
- [상태 전이](#상태-전이)
- [규칙 함수](#규칙-함수)
- [결과 예시](#결과-예시)

## 타입

필드만 고정한다.

**Order**

| 필드 | 타입 | 예시 | 설명 |
| --- | --- | --- | --- |
| orderId | string | `"3f2b8c1e-9a4d-4e7b-8c2a-1d5e6f7a8b9c"` | 주문 id. `createOrder` 안에서 Repository가 생성자로 받은 id 생성기로 발급한다([README.md](./README.md#id-발급)). 이후 이 값을 키로 저장·조회한다 |
| status | `"CREATED"\|"PAID"\|"PAYMENT_FAILED"\|"CANCELED"\|"REFUNDED"` | `"PAID"` | 상태 코드명 |
| items | OrderItem[] | - | 주문 품목 |
| subtotal | number | `10000` | 할인 전 금액(items의 price×qty 합, "주문금액") |
| couponCode | string \| null | `"ORDER_5000"` | 적용된 쿠폰 코드, 없으면 null |
| discount | number | `5000` | 할인액 |
| payable | number | `5000` | 결제금액(subtotal - discount) |
| failureReason | `{code, message}` \| null | `null` | 결제 실패 이유. PAYMENT_FAILED가 아니면 null. code는 INSUFFICIENT_CASH 하나, message는 [policy.md](../../planning/policy.md#결제-실패-사유) 문구 |

**OrderItem**

주문 생성 시점의 `title`/`price`를 스냅샷으로 저장한다. `/payment/:id`·`/orders/:id`가 상품 목록을 보여줄 때 `repository.getProducts()`를 다시 조회하지 않기 위해서다.

| 필드 | 타입 | 예시 | 설명 |
| --- | --- | --- | --- |
| productId | string | `"P1"` | 상품 id |
| title | string | `"상품 P1"` | 주문 시점 상품명 |
| price | number | `3000` | 주문 시점 단가(원) |
| qty | number | `2` | 수량(1~99) |

## 메서드

`Repository`의 메서드다([README.md](./README.md)).

**public**

| 메서드 | 시그니처 | 설명 |
| --- | --- | --- |
| getOrder | `(orderId: string): Order \| null` | sessionStorage에서 주문 하나를 조회한다. 없으면 `null` — 호출부(페이지 가드)가 404 화면으로 분기한다. 주문 없음은 에러 코드가 아니라 이 null 체크로 처리한다([errors.md](./errors.md#주문-없음)) |
| createOrder | `(lines: {productId, qty}[]): Result<Order>` | 체크한 품목만으로 CREATED 주문을 만들고 재고를 차감한다 |
| applyCoupon | `(orderId: string, couponCode: string): Result<Order>` | 쿠폰을 적용(다른 쿠폰이 있으면 교체)한다 |
| removeCoupon | `(orderId: string): Result<Order>` | 적용된 쿠폰을 해제한다 |
| pay | `(orderId: string): Result<Order>` | 결제를 시도한다. PAID와 PAYMENT_FAILED 둘 다 `ok: true`다 |
| cancel | `(orderId: string): Result<Order>` | 결제 대기 주문을 취소한다 |
| refund | `(orderId: string): Result<Order>` | 결제 완료 주문을 환불한다 |

- `orderId`를 받는 메서드는 페이지 가드를 통과한 뒤에만 호출되므로 주문이 있다고 가정한다([errors.md](./errors.md#주문-없음))

**private**

| 메서드 | 시그니처 | 설명 |
| --- | --- | --- |
| saveOrder | `(order: Order): void` | 주문을 sessionStorage에 생성/갱신(upsert)한다 |

## 메서드 내부 처리

모든 쓰기 메서드는 같은 순서를 따른다.

1. 저장소에서 필요한 값을 읽는다
2. [규칙 함수](#규칙-함수)를 호출한다
3. 실패(`ok: false`)면 아무것도 저장하지 않고 그 결과를 반환한다
4. 성공이면 결과를 저장하고 `{ ok: true, value: order }`를 반환한다

| 메서드 | 읽기 | 규칙 함수 | 저장 |
| --- | --- | --- | --- |
| `createOrder` | `getProducts` | `createOrder(lines, products, this.createId())` | `saveOrder`, `updateStock` |
| `applyCoupon` | `getOrder`, `getCoupons`(code로 찾기) | `applyCoupon` | `saveOrder` |
| `removeCoupon` | `getOrder` | `removeCoupon` | `saveOrder` |
| `pay` | `getOrder`, `getWallet`, `getProducts`(→ StockMap) | `pay` | `saveOrder` + PAID면 `saveWallet`, PAYMENT_FAILED면 `updateStock` |
| `cancel` | `getOrder`, `getProducts` | `cancel` | `saveOrder`, `updateStock` |
| `refund` | `getOrder`, `getWallet`, `getProducts` | `refund` | `saveOrder`, `updateStock`, `saveWallet` |

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

## 규칙 함수

비즈니스 규칙을 코드로 옮긴 순수 함수다. `src/repository/rules/`에 두고 Repository 메서드만 호출한다([structure.md](../architecture/structure.md)). 저장소와 화면은 모르고, 입력을 받아 `Result`만 반환한다. 이름이 public 메서드와 같으므로 Repository에서는 네임스페이스로 import한다(`import * as rules from './rules'`).

| 함수 | 입력 | 성공 `value` | 실패 code (검사 순서대로) |
| --- | --- | --- | --- |
| `createOrder` | `lines: {productId, qty}[]`(체크한 품목만), `products: Product[]`, `orderId: string` | `{ order, stock }` | EMPTY_CART → INVALID_QUANTITY → OUT_OF_STOCK |
| `evaluateCoupon` | `coupon: Coupon`, `order: Order` | `{ discount, payable }` | COUPON_NOT_APPLICABLE, MIN_AMOUNT_NOT_MET |
| `applyCoupon` | `order: Order`, `coupon: Coupon` | `Order` | INVALID_TRANSITION → `evaluateCoupon`의 실패 code |
| `removeCoupon` | `order: Order` | `Order` | INVALID_TRANSITION |
| `pay` | `order: Order`, `wallet: Wallet`, `stock: StockMap` | `{ order, wallet, stock }` | INVALID_TRANSITION |
| `cancel` | `order: Order`, `stock: StockMap` | `{ order, stock }` | INVALID_TRANSITION |
| `refund` | `order: Order`, `wallet: Wallet`, `stock: StockMap` | `{ order, wallet, stock }` | INVALID_TRANSITION |

- `orderId`는 밖에서 받는다. 규칙 함수 안에서 id를 만들면 결과가 매번 달라 테스트 기대값을 고정할 수 없다
- `createOrder`가 만드는 주문은 쿠폰 미적용 상태다 — `couponCode`/`failureReason`은 null, `discount`는 0, `payable`은 `subtotal`과 같다
- `evaluateCoupon`은 `getCouponOptions`의 사용 가능/불가 분류(`ok`면 사용 가능, [coupons.md](./coupons.md#메서드))와 `applyCoupon` 내부 검사에 같이 쓴다. 할인 계산식과 쿠폰별 실패 code는 [coupons.md](./coupons.md#할인-계산)를 따른다
- `applyCoupon`은 `couponCode`/`discount`/`payable`만 바꾸고 `subtotal`은 그대로 둔다. `removeCoupon`은 `couponCode`를 null, `discount`를 0, `payable`을 `subtotal`로 되돌린다
- `pay`: `wallet.cash >= order.payable`이면 PAID(`cash` 차감), 아니면 PAYMENT_FAILED(`failureReason` 설정, 재고 복원). 둘 다 `ok: true`다
- `cancel`·`refund`는 재고를 품목 수량만큼 복원하고, `refund`는 `payable`만큼 `cash`도 복원한다. 둘 다 `couponCode`/`discount`/`payable`은 그대로 둔다

## 결과 예시

성공 시 반환하는 `value`(주문)의 예시다.

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
