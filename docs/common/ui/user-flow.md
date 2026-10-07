# 사용자 플로우

Oct 6, 2026 · @DevYoung

화면과 사용자 행동, 분기만 다룬다. 레포지토리 호출 상세는 [docs/common/repository/](../repository/), 화면 배치는 [wireframe.md](./wireframe.md)를 따른다.

## 플로우

```mermaid
flowchart TD
    Start([시작]) --> Cart["/cart<br/>상품 선택, 수량 조절"]
    Cart -->|주문하기 클릭| CreateCheck{생성 가능?}
    CreateCheck -->|실패: 빈 장바구니 / 수량 오류 / 재고 부족| Cart
    CreateCheck -->|성공| Payment["/payment/:id<br/>쿠폰 선택"]
    Payment -->|취소| Cart
    Payment -->|결제하기 클릭| PayCheck{현금 ≥ 결제금액?}
    PayCheck -->|아니오| Failed["/orders/:id<br/>영수증: 결제 실패"]
    PayCheck -->|예| Paid["/orders/:id<br/>영수증: 결제 완료"]
    Paid -->|환불 클릭| Refunded["/orders/:id<br/>영수증: 환불 완료"]
    Paid --> End1([종료])
    Refunded --> End2([종료])
    Failed --> End3([종료])

    DirectAccess([북마크 등으로<br/>직접 접근]) --> GuardCheck{주문 존재 &&<br/>이 라우트 상태 맞음?}
    GuardCheck -->|아니오| NotFound["주문 없음(404)<br/>back-to-cart-button"]
    GuardCheck -->|예| Payment
    GuardCheck -->|예| Paid
    GuardCheck -->|예| Failed
    NotFound -->|돌아가기 클릭| Cart
```

## 분기 이유

| 분기 | 이유 |
| --- | --- |
| 생성 실패 시 `/cart`에 머무름 | 주문이 안 생겼으니 이동할 다음 화면이 없음 |
| 취소 시 `/cart`로 돌아감(영수증 없음) | 결제 시도 자체가 없었던 거라 보여줄 이력이 없음 |
| 결제 실패도 `/orders/:id`로 이동(영수증 있음) | 결제를 "시도"한 이력이라 실패 이유와 함께 남김 |
| 직접 접근 시 가드 실패하면 자동 리다이렉트 대신 404 화면 | sessionStorage는 탭 닫으면 사라져서 북마크 재진입 시 주문이 없을 수 있음. 가드 규칙은 architecture/tech-stack.md |
