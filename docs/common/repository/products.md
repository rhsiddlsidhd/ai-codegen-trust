# 상품 레포지토리

Oct 6, 2026 · @DevYoung

상품/재고 조회·갱신만 다룬다. 쿠폰은 [coupons.md](./coupons.md), 주문은 [orders.md](./orders.md), 에러 코드는 [errors.md](./errors.md)를 따른다.

## 목차

- [타입](#타입)
- [함수](#함수)
- [시드 데이터(고정)](#시드-데이터고정)

## 타입

필드만 고정한다.

**Product**

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| productId | string | 상품 id |
| title | string | 화면에 노출할 상품명 |
| des | string | 화면에 노출할 짧은 설명 |
| price | number | 단가(원) |
| stock | number | 현재 재고 |

**StockMap**

맵 구조라 배열형보다 타입 선언으로 고정한다. 재고만 가볍게 주고받을 때 쓰는 축소형으로, `Product`와는 목적이 다르다.

```
StockMap = { [productId: string]: number }
```
예시: `{"P1":5,"P2":3}`

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| key(productId) | string | 상품 id |
| value(stock) | number | 해당 상품 현재 재고 |

## 함수

| 함수 | 시그니처 | 설명 |
| --- | --- | --- |
| getProducts | `(): Product[]` | sessionStorage에서 상품 목록을 읽는다. 저장소가 비어 있으면(첫 로드) 아래 시드 데이터로 채운 뒤 반환한다 |
| updateStock | `(stock: StockMap): void` | 주문 생성·결제 실패·취소·환불 뒤 도메인 모듈이 계산한 새 `StockMap`을 sessionStorage에 반영한다 |

## 시드 데이터(고정)

상품은 아래 2종으로 고정이다(쿠폰 조건 테스트와 맞물림: C1은 P1을 대상 지정, C2/C3 금액 조건은 P1/P2 수량 조합으로 충족 가능). 추가·변경 없음.

```json
[
  { "productId": "P1", "title": "상품 P1", "des": "저가 상품", "price": 3000, "stock": 5 },
  { "productId": "P2", "title": "상품 P2", "des": "고가 상품", "price": 10000, "stock": 3 }
]
```
