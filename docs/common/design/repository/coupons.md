# 쿠폰 레포지토리

Oct 6, 2026 · @DevYoung

쿠폰 조회와 결제금액 계산을 타입 기준으로 다룬다. 쿠폰 종류·목록·할인 방식의 비즈니스 규칙은 [policy.md](../../planning/policy.md#쿠폰), 상품은 [products.md](./products.md), 주문은 [orders.md](./orders.md), 에러 코드는 [errors.md](./errors.md)를 따른다.

## 목차

- [타입](#타입)
- [메서드](#메서드)
- [할인 계산](#할인-계산)
- [시드 데이터(고정)](#시드-데이터고정)

## 타입

필드만 고정한다.

**Coupon**

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| code | string | 쿠폰 코드 |
| type | `"C1"\|"C2"\|"C3"\|"C4"` | 종류. 기획 명칭과의 대응은 아래 condition 표 |
| condition | object | 종류별 상이, 아래 표 참고 |
| benefit | object | 할인 내용, 아래 표 참고 |

**condition** (종류별 모양이 다름)

| type | 필드 | 예시 | 설명 |
| --- | --- | --- | --- |
| C1 | `targetProductId: string` | `{"targetProductId":"P1"}` | 대상 상품 쿠폰 |
| C2 | `minLineAmount: number` | `{"minLineAmount":20000}` | 고액 라인 쿠폰 |
| C3 | `minOrderAmount: number` | `{"minOrderAmount":10000}` | 최소 주문금액 쿠폰 |
| C4 | (없음) | `{}` | 전체 주문 쿠폰 |

**benefit** (공통 모양)

| 필드 | 타입 | 예시 | 설명 |
| --- | --- | --- | --- |
| discountType | `"FLAT"\|"RATE"` | `"RATE"` | 정액/정률 |
| value | number | `20` | 금액(원) 또는 비율(%) |
| maxDiscount | number \| null | `3000` | 정률 상한, 없으면 null |

## 메서드

`Repository`의 메서드다([README.md](./README.md)).

| 메서드 | 시그니처 | 설명 |
| --- | --- | --- |
| getCoupons | `(): Coupon[]` | sessionStorage에서 쿠폰 정책 목록을 읽는다. 저장소가 비어 있으면(첫 로드) 아래 시드 데이터로 채운 뒤 반환한다. 쿠폰은 소모되지 않아 쓰기 함수가 없다 |

## 할인 계산

[policy.md](../../planning/policy.md#쿠폰)의 할인 규칙을 필드 기준으로 옮긴 것이다.

| type | 기준 금액(`base`) |
| --- | --- |
| C1 | `targetProductId`와 같은 `productId` 품목의 `price × qty` |
| C2 | `price × qty`가 `minLineAmount` 이상인 품목들의 `price × qty` 합 |
| C3, C4 | `subtotal` |

- FLAT: `discount = min(value, base)`
- RATE: `discount = floor(base × value / 100)`, `maxDiscount`가 null이 아니면 `min(그 값, maxDiscount)`
- `payable = subtotal - discount`

시드 쿠폰 적용 예시:

| 주문 | 쿠폰 | 계산 | discount | payable |
| --- | --- | --- | --- | --- |
| P1×1 (3000) | `ONLY_P1_5000` | P1 라인 3000, FLAT이 base 초과 → 3000 | 3000 | 0 |
| P1×2 (6000) | `ONLY_P1_5000` | P1 라인 6000 | 5000 | 1000 |
| P2×2 + P1×1 (23000) | `HIGH_LINE_10` | 20000 이상 라인은 P2 라인(20000)뿐 → 10% | 2000 | 21000 |
| P2×1 (10000) | `ORDER_5000` | subtotal 10000 | 5000 | 5000 |
| P2×1 (10000) | `RATE20_CAP3000` | 10000 × 20% | 2000 | 8000 |
| P2×2 (20000) | `RATE20_CAP3000` | 20000 × 20% = 4000 → maxDiscount 3000 | 3000 | 17000 |

## 시드 데이터(고정)

4장 외 추가·변경 없음.

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
