# 레포지토리 명세

Oct 6, 2026 · @DevYoung

타입, 저장소 접근 메서드, 공통 에러 코드를 정리한 디렉토리다. 서버가 없어서(네트워크 호출 자체가 없음, [tech-stack.md](../architecture/tech-stack.md)) 여기서 다루는 건 HTTP 엔드포인트가 아니라 `class Repository`의 메서드다. `src/repository/index.ts`가 싱글턴 `export const repository = new Repository()`를 노출하고, 사용하는 쪽은 이걸 import해서 쓴다.

## 저장 키

| 키 | 값 | 비고 |
| --- | --- | --- |
| `products` | `Product[]` | 재고는 각 `Product.stock`. `updateStock`은 이 값만 덮어쓴다 |
| `coupons` | `Coupon[]` | 읽기 전용 |
| `orders` | `{ [orderId]: Order }` | `saveOrder`는 해당 id만 갱신한다 |
| `wallet` | `Wallet` | — |

## 목차

- [errors.md](./errors.md) — 에러 반환 모양(`error: {code, message}`), 에러 코드 목록, 주문 없음 처리. 다른 파일은 코드만 참조한다
- [products.md](./products.md) — `getProducts()`/`updateStock()`, `Product`/`StockMap` 타입
- [coupons.md](./coupons.md) — `getCoupons()`, `Coupon`/`condition`/`benefit` 타입, 할인 계산식, 시드 쿠폰
- [orders.md](./orders.md) — `getOrder()`/`saveOrder()`, `Order`/`OrderItem` 타입
- [wallet.md](./wallet.md) — `getWallet()`/`saveWallet()`, `Wallet` 타입, 시드 현금
