# 레포지토리 명세

Oct 6, 2026 · @DevYoung

도메인별 레포지토리 모듈 함수 계약과 공통 에러 코드를 정리한 디렉토리다. 서버가 없어서(네트워크 호출 자체가 없음, [tech-stack.md](../architecture/tech-stack.md)) 여기서 다루는 건 HTTP 엔드포인트가 아니라 `src/repository/index.ts`가 노출하는 함수 시그니처다. UI 라우트와 data-testid는 [wireframe.md](../ui/wireframe.md)를 따른다.

## 목차

- [errors.md](./errors.md) — 도메인 모듈 공통 에러 코드(`error.code`/`error.message`). 다른 파일은 코드만 참조한다
- [products.md](./products.md) — `getProducts()`/`updateStock()`, `Product`/`StockMap` 타입
- [coupons.md](./coupons.md) — `getCoupons()`, `Coupon`/`condition`/`benefit` 타입
- [orders.md](./orders.md) — `getOrder()`/`saveOrder()`, 동작별(생성/쿠폰/결제/취소/환불) 처리 흐름, `Order`/`OrderItem` 타입
- [wallet.md](./wallet.md) — `getWallet()`/`saveWallet()`, `Wallet` 타입, 결제/환불에 따른 cash 차감·복원 시점
