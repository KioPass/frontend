# 키오패스 (KioPass)

바코드 스캔 기반 무인 결제 시스템 — Flutter 앱 + Spring Boot 백엔드

---

## 기술 스택

| 구분 | 기술 |
|---|---|
| 앱 | Flutter 3.x (Dart 3.11) |
| 백엔드 | Spring Boot 3.5, Java 17 |
| DB | H2 (파일 모드) |
| 인증 | JWT + Kakao / Naver OAuth2 |
| 결제 | Toss Payments (JS SDK) |

---

## 사전 준비

- Flutter SDK 3.x 이상
- Java 17 이상
- Xcode (iOS 빌드 시)
- Android Studio (Android 빌드 시)
- ngrok (Toss 결제 테스트 시)

---

## 백엔드 실행

### 1. 설정 파일 생성

```bash
cd backend/src/main/resources
cp application.properties.example application.properties
```

`application.properties` 열어서 아래 값 입력:

```properties
# Kakao OAuth
spring.security.oauth2.client.registration.kakao.client-id=발급받은_키

# Naver OAuth
spring.security.oauth2.client.registration.naver.client-id=발급받은_키
spring.security.oauth2.client.registration.naver.client-secret=발급받은_시크릿

# Toss Payments
toss.client-key=test_ck_...
toss.secret-key=test_sk_...

# JWT (32자 이상 아무 문자열)
jwt.secret=your-secret-key-here

# 관리자 설정 시크릿
admin.secret=원하는_시크릿
```

### 2. 실행

```bash
cd backend
./gradlew bootRun
```

서버 기본 포트: `http://localhost:8080`

### 3. H2 콘솔 (DB 확인)

`http://localhost:8080/h2-console`
- JDBC URL: `jdbc:h2:~/kio`
- 계정: `sa` / 비밀번호 없음

---

## 프론트엔드 실행

### 1. 패키지 설치

```bash
cd frontend
flutter pub get
```

### 2. 서버 주소 설정

`frontend/lib/services/api_service.dart` 상단에서 IP 변경:

```dart
const String kBaseUrl = 'http://본인IP:8080';   // 로컬 테스트
const String kTossBase = 'https://ngrok주소';    // Toss 결제 (ngrok 필요)
```

> 본인 IP 확인: `ifconfig | grep "inet " | grep -v 127`

### 3. 실행

```bash
# iOS
flutter run -d <아이폰 기기 ID>

# Android
flutter run -d <안드로이드 기기 ID>

# 연결된 기기 확인
flutter devices
```

---

## Toss 결제 테스트 (ngrok)

Toss는 HTTPS 콜백이 필요해서 ngrok 터널링이 필요해요.

```bash
# ngrok 설치 후
ngrok http 8080
```

발급된 주소를 `api_service.dart`의 `kTossBase`에 입력.

---

## 관리자 계정 설정

백엔드 실행 후 터미널에서:

```bash
curl -X POST http://localhost:8080/api/admin/setup \
  -H "Content-Type: application/json" \
  -d '{"email":"가입한이메일@gmail.com","secret":"application.properties에_설정한_admin.secret"}'
```

이후 앱에서 **로그아웃 → 재로그인** 하면 관리자 메뉴 활성화.

---

## Firebase 설정 (푸시 알림)

1. [Firebase 콘솔](https://console.firebase.google.com)에서 프로젝트 생성
2. iOS 앱 등록 → `GoogleService-Info.plist` → `frontend/ios/Runner/` 에 추가
3. Android 앱 등록 → `google-services.json` → `frontend/android/app/` 에 추가

---

## 주요 기능

- 카카오 / 네이버 소셜 로그인
- 바코드 스캔으로 상품 추가 → 장바구니 → 토스페이 결제
- 판매자 대시보드 (매출·재고 관리)
- 판매자 전환 신청 → 관리자 심사 승인
- 1:1 고객 문의 / 관리자 답변
- 다크모드 지원
