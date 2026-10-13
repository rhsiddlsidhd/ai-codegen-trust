# 쿠폰 레포지토리

Oct 6, 2026 · @DevYoung

쿠폰 조회와 결제금액 계산만 다룬다. 상품은 [products.md](./products.md), 주문은 [orders.md](./orders.md), 에러 코드는 [errors.md](./errors.md)를 따른다.

## 목차

- [타입](#타입)
- [함수](#함수)
- [할인 계산](#할인-계산)
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

## 할인 계산

할인액은 종류별 **기준 금액**에 benefit을 적용해 구한다.

| type | 기준 금액 |
| --- | --- |
| C1 | 대상 상품(`targetProductId`) 라인 금액 |
| C2 | `minLineAmount` 이상인 라인 금액의 합 |
| C3, C4 | 주문 전체(`subtotal`) |

- 정액(FLAT): `value`를 할인하되 기준 금액을 넘지 않는다. 그래서 `payable`은 0 미만이 되지 않는다
- 정률(RATE): 기준 금액 × `value`% 에서 원 미만은 버린다. `maxDiscount`가 있으면 그 값이 상한이다

시드 쿠폰 적용 예시:

| 주문 | 쿠폰 | 계산 | 할인 | 결제금액 |
| --- | --- | --- | --- | --- |
| P1×1 (3000) | `ONLY_P1_5000` | P1 라인 3000, 정액이 기준 금액 초과 → 3000 | 3000 | 0 |
| P1×2 (6000) | `ONLY_P1_5000` | P1 라인 6000 | 5000 | 1000 |
| P2×2 + P1×1 (23000) | `HIGH_LINE_10` | 20000 이상 라인은 P2 라인(20000)뿐 → 10% | 2000 | 21000 |
| P2×1 (10000) | `ORDER_5000` | 주문 전체 10000 | 5000 | 5000 |
| P2×1 (10000) | `RATE20_CAP3000` | 10000 × 20% | 2000 | 8000 |
| P2×2 (20000) | `RATE20_CAP3000` | 20000 × 20% = 4000 → 상한 3000 | 3000 | 17000 |

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
