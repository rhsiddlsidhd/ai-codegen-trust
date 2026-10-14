# Context

Oct 14, 2026 · @DevYoung

전역 상태와, Repository 주문 동작을 호출해 화면 쪽 후처리(cash 갱신, 토스트)를 붙이는 액션만 다룬다. 읽기 → 규칙 → 저장은 Repository 안에서 끝난다([design/repository/](../repository/README.md#서버-역할)).

## 목차

- [구성](#구성)
- [액션 공통 흐름](#액션-공통-흐름)

## 구성

| Context | 상태 | 액션 |
| --- | --- | --- |
| `WalletContext` | `cash` (초기값 `repository.getWallet().cash`) | — |
| `OrderContext` | — | `createOrder(lines)`, `applyCoupon(orderId, couponCode)`, `removeCoupon(orderId)`, `pay(orderId)`, `cancel(orderId)`, `refund(orderId)`. 모두 `Result<Order>` 반환 |

- `OrderContext`는 `WalletContext` 안쪽에 두고, 지갑이 바뀌는 액션 뒤에 `cash`를 갱신한다. 헤더는 `WalletContext`의 `cash`를 표시한다
- 읽기 전용 데이터(상품 목록, 쿠폰 목록과 사용 가능 분류, 주문 조회)는 Context에 두지 않고 페이지가 `repository`에서 직접 읽는다
- 장바구니 상태(체크, 수량)는 Context에 두지 않고 /cart 페이지 안에만 둔다

## 액션 공통 흐름

1. 같은 이름의 `repository` 메서드를 호출한다(`pay(orderId)` → `repository.pay(orderId)`, [orders.md](../repository/orders.md#메서드)). 주문을 다루는 액션은 페이지 가드를 통과한 뒤에만 호출되므로 주문이 있다고 가정한다([errors.md](../repository/errors.md#주문-없음))
2. 실패(`ok: false`)면 `error.message`를 전역 토스트(sonner `toast`, [components.md](../ui/components.md#지정-컴포넌트))에 띄운다. 단, `COUPON_NOT_APPLICABLE`·`MIN_AMOUNT_NOT_MET`는 띄우지 않는다
3. 성공이고 지갑이 바뀌는 액션(`pay`, `refund`)이면 `repository.getWallet().cash`로 `WalletContext`의 `cash`를 갱신한다
4. 받은 `Result`를 그대로 반환한다. 페이지는 이 값으로 화면을 갱신하거나 이동한다
