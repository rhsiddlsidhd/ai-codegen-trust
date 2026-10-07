# 와이어프레임

Oct 6, 2026 · @DevYoung

이 문서는 라우트별 화면 레이아웃(요소 배치)과 그 안에 쓰이는 data-testid만 다룬다. 라우트 간 이동·리다이렉트 규칙은 [user-flow.md](./user-flow.md), 컴포넌트 제작 규칙은 [components.md](./components.md), 레포지토리 명세는 [docs/common/repository/](../repository/)를 따른다.

## 목차

- [UI 라우트](#ui-라우트)
- [전역 레이아웃](#전역-레이아웃)
- [/cart](#cart)
- [/payment/:id](#paymentid)
- [/orders/:id](#ordersid)
- [주문 없음(404)](#주문-없음404)
- [전역 토스트](#전역-토스트)
- [data-testid](#data-testid)

## UI 라우트

| 라우트 | 내용 |
| --- | --- |
| `/cart` | 상품 선택, 수량 조절. 쿠폰·결제는 여기서 안 함 |
| `/payment/:id` | CREATED 주문의 쿠폰 선택 + 결제/취소 |
| `/orders/:id` | 결과(PAID/PAYMENT_FAILED/CANCELED/REFUNDED) 영수증, PAID일 때만 환불 |

## 전역 레이아웃

보유 현금(`wallet-cash`)은 특정 라우트 요소가 아니라 공통 레이아웃(헤더)에 박아서 `/cart`, `/payment/:id`, `/orders/:id` 어디서든 보인다. 헤더 우측에 "[C 아이콘] 값" 형태로 둔다.

```
+--------------------------------------------------+
|  (헤더)                      [C] [wallet-cash]     |
+--------------------------------------------------+
|  (라우트별 내용)                                    |
+--------------------------------------------------+
```

## /cart

```
+--------------------------------------------------+
|  장바구니                                          |
+--------------------------------------------------+
|  [상품 title]                                      |
|  [상품 des]                                        |
|    수량 [cart-item-qty-input] ----                 |
+--------------------------------------------------+
|  [상품 title]                                      |
|  [상품 des]                                        |
|    수량 [cart-item-qty-input] ----                 |
+--------------------------------------------------+
|                          [create-order-button]     |
+--------------------------------------------------+
```

## /payment/:id

```
+--------------------------------------------------+
|  결제        주문 id: [order-id]                   |
+--------------------------------------------------+
|  선택한 상품                                        |
|  상품 title × 수량 (반복)                            |
+--------------------------------------------------+
|  통합 결제금액: [subtotal-amount]                    |
+--------------------------------------------------+
|  쿠폰                                              |
|  [coupon-tab-available] | [coupon-tab-unavailable]|
|  --------------------------------------------      |
|  [coupon-item-{code}]  [coupon-item-{code}] ...    |
+--------------------------------------------------+
|  최종 결제금액: [payable-amount]                     |
+--------------------------------------------------+
|           [cancel-button]     [pay-button]         |
+--------------------------------------------------+
```

## /orders/:id

```
+--------------------------------------------------+
|  영수증        주문 id: [order-id]                  |
+--------------------------------------------------+
|  상태: [order-status]                              |
|  품목: 상품 title × 수량 (반복)                       |
|  쿠폰: couponCode                                  |
|  통합 결제금액: [subtotal-amount]                    |
|  최종 결제금액: [payable-amount]                     |
+--------------------------------------------------+
|  실패 이유: [failure-reason]   (PAYMENT_FAILED일 때만)|
+--------------------------------------------------+
|  [refund-button]              (PAID일 때만)         |
+--------------------------------------------------+
```

## 주문 없음(404)

`/payment/:id`, `/orders/:id`에서 주문이 없거나(ORDER_NOT_FOUND) 그 라우트에 맞는 상태가 아니면, 같은 URL 자리에서 이 화면을 보여준다(자동 리다이렉트 아님). 가드 규칙은 [tech-stack.md](../architecture/tech-stack.md)를 따른다.

```
+--------------------------------------------------+
|  [not-found-message]                               |
|  주문을 찾을 수 없습니다                              |
+--------------------------------------------------+
|                          [back-to-cart-button]     |
+--------------------------------------------------+
```

## 전역 토스트

`error-message`는 라우트 안이 아니라 전역 토스트(shadcn Toast)로 뜬다. 세 라우트 어디서든 같은 토스트 레이어를 씀. 5000ms 후 자동으로 사라진다.

## data-testid

| data-testid | 라우트 | 내용 |
| --- | --- | --- |
| `wallet-cash` | 전역(레이아웃) | 보유 현금 표시 |
| `cart-item-qty-input` | /cart | 품목 수량 입력 |
| `create-order-button` | /cart | 주문 생성, 성공 시 `/payment/:id`로 이동 |
| `order-id` | /payment/:id, /orders/:id | 주문 id 표시 |
| `subtotal-amount` | /payment/:id, /orders/:id | 할인 전 통합 결제금액 |
| `coupon-tab-available`, `coupon-tab-unavailable`, `coupon-item-{code}` | /payment/:id | 사용 가능/불가 탭과 쿠폰 항목(선택) |
| `payable-amount` | /payment/:id, /orders/:id | 할인 적용된 최종 결제금액 |
| `pay-button` | /payment/:id | 결제 시도, 단일 버튼(결제 수단 선택 없음) |
| `cancel-button` | /payment/:id | 주문 취소, 성공 시 `/cart`로 이동 |
| `order-status` | /orders/:id | 상태 코드명(예: PAID) 표시 |
| `failure-reason` | /orders/:id | 결제 실패 이유(`failureReason.message`), PAYMENT_FAILED일 때만 렌더 |
| `refund-button` | /orders/:id | 전체 환불, PAID일 때만 렌더 |
| `error-message` | 전역(토스트) | 오류 코드명(예: OUT_OF_STOCK) 표시 |
| `not-found-message` | /payment/:id, /orders/:id (가드 실패 시) | 주문 없음 안내 |
| `back-to-cart-button` | /payment/:id, /orders/:id (가드 실패 시) | 클릭 시 `/cart`로 이동 |
