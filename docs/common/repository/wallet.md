# 지갑 레포지토리

Oct 6, 2026 · @DevYoung

보유 현금 조회·갱신만 다룬다. 차감/복원은 결제·환불 흐름의 side effect로 [orders.md](./orders.md)에서 호출되고, 여기선 저장소 접근 함수만 다룬다.

## 목차

- [타입](#타입)
- [함수](#함수)
- [시드 데이터(고정)](#시드-데이터고정)
- [차감/복원 시점](#차감복원-시점)

## 타입

**Wallet**

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| cash | number | 보유 현금(원) |

## 함수

| 함수 | 시그니처 | 설명 |
| --- | --- | --- |
| getWallet | `(): Wallet` | sessionStorage에서 지갑을 읽는다. 저장소가 비어 있으면(첫 로드) 아래 시드 데이터로 채운 뒤 반환한다 |
| saveWallet | `(wallet: Wallet): void` | 결제 성공 또는 환불로 변경된 cash를 sessionStorage에 반영한다 |

## 시드 데이터(고정)

cash는 8,000원 하나로 고정이다. 추가·변경 없음.

```json
{ "cash": 8000 }
```

## 차감/복원 시점

| 시점 | cash 변화 |
| --- | --- |
| 결제 시도 성공(PAID) | `payable`만큼 차감, `saveWallet` 호출 |
| 결제 시도 실패(PAYMENT_FAILED) | 변화 없음(차감한 적 없음), `saveWallet` 호출 안 해도 됨 |
| 취소 | 변화 없음 |
| 환불 | 차감했던 `payable`만큼 복원, `saveWallet` 호출 |
