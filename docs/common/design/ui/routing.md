# 라우팅 & 진입 판정

Oct 15, 2026 · @DevYoung

라우트 테이블, 주문 라우트의 진입 판정, 액션 결과에 따른 화면 이동만 다룬다. 어떤 상태에서 어떤 화면이 보이는지는 [user-flow.md](../../planning/user-flow.md#화면-표시-규칙), 주문 조회 계약은 [orders.md](../repository/orders.md#메서드), 액션은 [design/context/](../context/README.md)를 따른다.

## 목차

- [라우트 테이블](#라우트-테이블)
- [진입 판정](#진입-판정)
- [판정표](#판정표)
- [액션 결과에 따른 이동](#액션-결과에-따른-이동)

## 라우트 테이블

| 경로 | 화면 | 진입 판정 |
| --- | --- | --- |
| `/cart` | 장바구니 | 없음 |
| `/payment/:id` | 결제 | 있음 |
| `/orders/:id` | 영수증 | 있음 |

## 진입 판정

1. 페이지가 렌더할 때 URL의 `:id`로 `repository.getOrder(id)`를 호출한다. 읽기 전용 조회라 Context를 거치지 않는다([context](../context/README.md#구성))
2. 결과(`Order | null`)를 [판정표](#판정표)에 대입한다. 404면 같은 URL에서 주문 없음 화면을 렌더하고 리다이렉트하지 않는다([wireframe.md](../../planning/wireframe.md#주문-없음404))
3. 판정을 통과한 페이지만 주문 액션을 호출한다. 그래서 액션과 Repository 메서드는 주문이 있다고 가정한다([errors.md](../repository/errors.md#주문-없음))

## 판정표

상태 코드와 표시명의 대응은 [orders.md](../repository/orders.md#상태-전이)를 따른다.

| 라우트 | 주문 없음(`null`) | CREATED | PAID | PAYMENT_FAILED | CANCELED | REFUNDED |
| --- | --- | --- | --- | --- | --- | --- |
| `/payment/:id` | 404 | 렌더 | 404 | 404 | 404 | 404 |
| `/orders/:id` | 404 | 404 | 렌더 | 렌더 | 404 | 렌더 |

## 액션 결과에 따른 이동

실패(`ok: false`)면 어느 동작이든 이동하지 않고 그 화면에 머문다. 안내는 액션이 처리한다([context](../context/README.md#액션-공통-흐름)).

| 화면 | 동작 | 호출 | 성공 시 |
| --- | --- | --- | --- |
| `/cart` | 주문하기 | `createOrder(lines)` | `/payment/{orderId}`로 이동 |
| `/payment/:id` | 쿠폰 선택·교체·해제 | `applyCoupon` / `removeCoupon` | 머무름, 반환된 주문으로 화면 갱신 |
| `/payment/:id` | 결제 | `pay(orderId)` | PAID·PAYMENT_FAILED 모두 `/orders/{orderId}`로 이동 |
| `/payment/:id` | 취소 | `cancel(orderId)` | `/cart`로 이동 |
| `/orders/:id` | 환불 | `refund(orderId)` | 머무름, 반환된 주문(REFUNDED)으로 영수증 갱신 |
| `/orders/:id`, 404 화면 | 장바구니로 | — | `/cart`로 이동 |
