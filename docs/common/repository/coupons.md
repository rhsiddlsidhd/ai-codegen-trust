# 쿠폰 레포지토리

Oct 6, 2026 · @DevYoung

쿠폰 조회와 결제금액 계산만 다룬다. 상품은 [products.md](./products.md), 주문은 [orders.md](./orders.md), 에러 코드는 [errors.md](./errors.md)를 따른다.

## 목차

- [타입](#타입)
- [함수](#함수)
- [시드 데이터(고정)](#시드-데이터고정)

## 타입

필드만 고정한다.

**Coupon**

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| code | string | 쿠폰 코드 |
| type | `"C1"\|"C2"\|"C3"\|"C4"` | 종류 |
| condition | object | 종류별 상이, 아래 표 참고 |
| benefit | object | 할인 내용, 아래 표 참고 |

**condition** (종류별 모양이 다름)

| type | 필드 | 예시 | 설명 |
| --- | --- | --- | --- |
| C1 | `targetProductId: string` | `{"targetProductId":"P1"}` | 대상 상품 지정 |
| C2 | `minLineAmount: number` | `{"minLineAmount":20000}` | 라인 금액(단가×수량) 조건 |
| C3 | `minOrderAmount: number` | `{"minOrderAmount":10000}` | 최소 주문금액 |
| C4 | (없음) | `{}` | 주문 전체, 추가 조건 없음 |

**benefit** (공통 모양)

| 필드 | 타입 | 예시 | 설명 |
| --- | --- | --- | --- |
| discountType | `"FLAT"\|"RATE"` | `"RATE"` | 정액/정률 |
| value | number | `20` | 금액(원) 또는 비율(%) |
| maxDiscount | number \| null | `3000` | 정률 상한, 없으면 null |

## 함수

| 함수 | 시그니처 | 설명 |
| --- | --- | --- |
| getCoupons | `(): Coupon[]` | sessionStorage에서 쿠폰 정책 목록을 읽는다. 저장소가 비어 있으면(첫 로드) 아래 시드 데이터로 채운 뒤 반환한다. 쿠폰은 소모되지 않아 쓰기 함수가 없다 |

## 시드 데이터(고정)

4종(C1~C4) 외 추가·변경 없음.

```json
[
  {
    "code": "ONLY_P1_5000",
    "type": "C1",
    "condition": { "targetProductId": "P1" },
    "benefit": { "discountType": "FLAT", "value": 5000, "maxDiscount": null }
  },
  {
    "code": "HIGH_LINE_10",
    "type": "C2",
    "condition": { "minLineAmount": 20000 },
    "benefit": { "discountType": "RATE", "value": 10, "maxDiscount": null }
  },
  {
    "code": "ORDER_5000",
    "type": "C3",
    "condition": { "minOrderAmount": 10000 },
    "benefit": { "discountType": "FLAT", "value": 5000, "maxDiscount": null }
  },
  {
    "code": "RATE20_CAP3000",
    "type": "C4",
    "condition": {},
    "benefit": { "discountType": "RATE", "value": 20, "maxDiscount": 3000 }
  }
]
```
