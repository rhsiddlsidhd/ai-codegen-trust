# 레포지토리 명세

Oct 6, 2026 · @DevYoung

타입, Repository 메서드, 비즈니스 규칙, 공통 에러 코드를 정리한 디렉토리다. 서버가 없어서(네트워크 호출 자체가 없음, [tech-stack.md](../architecture/tech-stack.md)) `class Repository`가 서버 역할을 한다. 여기서 다루는 건 HTTP 엔드포인트가 아니라 그 메서드다. `src/repository/index.ts`가 싱글턴 `export const repository = new Repository()`를 노출하고, 사용하는 쪽은 이걸 import해서 쓴다.

## 서버 역할

- **public 메서드**만 바깥(페이지, Context)이 호출한다. 읽기(`getProducts`, `getCoupons`, `getCouponOptions`, `getOrder`, `getWallet`)와 주문 동작(`createOrder`, `applyCoupon`, `removeCoupon`, `pay`, `cancel`, `refund`)이다
- 주문 동작 메서드는 읽기 → 규칙 판정 → 저장을 안에서 끝내고 `Result`를 반환한다([orders.md](./orders.md#메서드-내부-처리), [errors.md](./errors.md#반환-모양)). 호출하는 쪽은 규칙을 모른다
- **private 메서드**(`saveOrder`, `updateStock`, `saveWallet`)는 바깥에서 호출할 수 없다. 규칙을 거치지 않은 저장을 막기 위해서다
- 규칙 판정은 `src/repository/rules/`의 순수 함수가 한다([orders.md](./orders.md#규칙-함수)). 저장소를 모르므로 Repository 없이 단위 테스트한다

## id 발급

주문 id는 서버처럼 Repository가 발급한다. 생성자에서 id 생성기를 받아 테스트에서 값을 고정할 수 있게 한다.

```ts
new Repository({ createId: () => crypto.randomUUID() }) // 기본값(src/repository/index.ts)
new Repository({ createId: () => 'order-1' })           // 테스트
```

## 저장 키

| 키 | 값 | 비고 |
| --- | --- | --- |
| `products` | `Product[]` | 재고는 각 `Product.stock`. `updateStock`은 이 값만 덮어쓴다 |
| `coupons` | `Coupon[]` | 읽기 전용 |
| `orders` | `{ [orderId]: Order }` | `saveOrder`는 해당 id만 갱신한다 |
| `wallet` | `Wallet` | — |

## 목차

- [errors.md](./errors.md) — 반환 모양(`Result`), 에러 코드 목록, 주문 없음 처리. 다른 파일은 코드만 참조한다
- [products.md](./products.md) — `getProducts()`/`updateStock()`, `Product`/`StockMap` 타입
- [coupons.md](./coupons.md) — `getCoupons()`/`getCouponOptions()`, `Coupon`/`condition`/`benefit` 타입, 할인 계산식, 쿠폰별 실패 code, 시드 쿠폰
- [orders.md](./orders.md) — `getOrder()`와 주문 동작 메서드, `Order`/`OrderItem` 타입, 상태 전이, 규칙 함수
- [wallet.md](./wallet.md) — `getWallet()`/`saveWallet()`, `Wallet` 타입, 시드 현금
