# Context

Oct 14, 2026 · @DevYoung

전역 상태와, "읽기 → 도메인 → 저장"을 묶는 액션만 다룬다. 규칙 계산은 [design/domain/](../domain/), 저장은 [design/repository/](../repository/)를 따른다.

## 목차

- [구성](#구성)
- [액션 공통 흐름](#액션-공통-흐름)
- [액션별 호출](#액션별-호출)

## 구성

| Context | 상태 | 액션 |
| --- | --- | --- |
| `WalletContext` | `cash` (초기값 `repository.getWallet().cash`) | — |
| `OrderContext` | — | `createOrder(lines)`, `applyCoupon(orderId, couponCode)`, `removeCoupon(orderId)`, `pay(orderId)`, `cancel(orderId)`, `refund(orderId)`. 모두 `Result<Order>` 반환 |

- `OrderContext`는 `WalletContext` 안쪽에 두고, 지갑이 바뀌는 액션 뒤에 `cash`를 갱신한다. 헤더는 `WalletContext`의 `cash`를 표시한다
- 읽기 전용 데이터(상품 목록, 쿠폰 목록, 주문 조회)는 Context에 두지 않고 페이지가 `repository`에서 직접 읽는다
- 장바구니 상태(체크, 수량)는 Context에 두지 않고 /cart 페이지 안에만 둔다

## 액션 공통 흐름

1. `repository`에서 필요한 값을 읽는다. 주문을 다루는 액션은 페이지 가드를 통과한 뒤에만 호출되므로 주문이 있다고 가정한다([errors.md](../repository/errors.md#주문-없음))
2. 도메인 함수를 호출한다
3. 실패(`ok: false`)면 아무것도 저장하지 않고, `error.message`를 전역 토스트(sonner `toast`, [components.md](../ui/components.md#지정-컴포넌트))에 띄운다. 단, `COUPON_NOT_APPLICABLE`·`MIN_AMOUNT_NOT_MET`는 띄우지 않는다
4. 성공이면 결과를 `repository`에 저장하고, 지갑이 바뀌었으면 `WalletContext`의 `cash`를 갱신한다
5. 결과 주문을 반환한다. 페이지는 이 값으로 화면을 갱신하거나 이동한다

## 액션별 호출

| 액션 | 읽기 | 도메인 | 저장 |
| --- | --- | --- | --- |
| `createOrder` | `getProducts` | `createOrder(lines, products, crypto.randomUUID())` | `saveOrder`, `updateStock` |
| `applyCoupon` | `getOrder`, `getCoupons`(code로 찾기) | `applyCoupon` | `saveOrder` |
| `removeCoupon` | `getOrder` | `removeCoupon` | `saveOrder` |
| `pay` | `getOrder`, `getWallet`, `getProducts`(→ StockMap) | `pay` | `saveOrder` + PAID면 `saveWallet`, PAYMENT_FAILED면 `updateStock` |
| `cancel` | `getOrder`, `getProducts` | `cancel` | `saveOrder`, `updateStock` |
| `refund` | `getOrder`, `getWallet`, `getProducts` | `refund` | `saveOrder`, `updateStock`, `saveWallet` |
