# 주문 레포지토리

Oct 6, 2026 · @DevYoung

주문 타입과 주문 저장 메서드만 다룬다. 주문을 바꾸는 규칙은 [design/domain/](../domain/), 액션 흐름은 [design/context/](../context/)를 따른다. 상품은 [products.md](./products.md), 쿠폰은 [coupons.md](./coupons.md), 지갑은 [wallet.md](./wallet.md), 에러 코드는 [errors.md](./errors.md)를 따른다.

## 타입

필드만 고정한다.

**Order**

| 필드 | 타입 | 예시 | 설명 |
| --- | --- | --- | --- |
| orderId | string | `"3f2b8c1e-9a4d-4e7b-8c2a-1d5e6f7a8b9c"` | 주문 id. 주문 생성 시 `OrderContext`가 `crypto.randomUUID()`로 발급해 도메인 `createOrder`에 넘긴다(네이티브 API, 별도 의존성 없음). 이후 `saveOrder`/`getOrder`가 이 값을 키로 저장·조회한다 |
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

| 메서드 | 시그니처 | 설명 |
| --- | --- | --- |
| getOrder | `(orderId: string): Order \| null` | sessionStorage에서 주문 하나를 조회한다. 없으면 `null` — 호출부(페이지 가드)가 404 화면으로 분기한다. 주문 없음은 에러 코드가 아니라 이 null 체크로 처리한다([errors.md](./errors.md#주문-없음)) |
| saveOrder | `(order: Order): void` | 주문을 sessionStorage에 생성/갱신(upsert)한다 |

