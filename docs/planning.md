# NFC Link Manager 기획안

이 문서는 Flutter 모바일 앱 **NFC Link Manager**의 MVP 기획 방향을 정리한다. 화면별 상세 요구사항은 `docs/feature-spec.md`에 두고, 이 문서는 서비스 목표, MVP 범위, 핵심 의사결정, 개발 순서를 기준으로 유지한다.

## 1. Service Goal

- 사용자가 원하는 프로필 링크를 NFC 태그에 쉽게 저장할 수 있는 Android/iOS Flutter 앱을 만든다.
- 저장 가능한 링크 유형은 다음과 같다.
  - Instagram
  - LinkedIn
  - GitHub
  - Linktree
  - Portfolio
  - 직접 URL 입력
- 앱은 NFC 태그에 URL을 쓴 뒤 같은 태그를 다시 읽어 `입력 URL`과 `실제 저장 URL`이 같은지 검증한다.
- MVP는 서버/DB 없이 동작한다. 핵심 데이터 저장 매체는 서버나 앱 내부 DB가 아니라 NFC 태그 자체다.
- NFC 태그에는 URL을 NDEF URL Record 형태로 저장한다.
- Android/iOS에서 동작하는 Flutter 앱을 목표로 하되, NFC 동작 차이는 플랫폼별 로직으로 분리한다.

## 2. MVP Scope

### 포함 범위

- Flutter 기반 모바일 앱
- URL 입력
- Instagram 계정명 기반 URL 자동 생성
- 전체 URL 입력 및 정규화
- URL 형식 검사
- NFC 태그에 NDEF URL Record 쓰기
- NFC 태그 읽기
- 쓰기 후 검증
- 태그 상태 확인
- NTAG213 기준 144 byte 저장 가능 여부 계산
- NFC 실패 상황에 대한 사용자 메시지 제공
- 최근 URL 로컬 저장

### 제외 범위

- 서버 API
- DB
- 로그인
- 사용자 계정
- 클라우드 동기화
- 웹 관리자 페이지
- 결제
- 고급 통계
- NFC 태그 구매/재고 관리

## 3. Technical Stack

| 구분 | 선택 | 설명 |
| --- | --- | --- |
| Framework | Flutter | Android/iOS 단일 코드베이스로 MVP를 빠르게 구현한다. |
| Language | Dart | Flutter 기본 언어를 사용한다. |
| NFC package | `nfc_manager` | Android/iOS NFC 기능을 Flutter에서 다루기 위한 패키지 후보로 사용한다. |
| Routing | `go_router` | 명시적인 화면 전환과 확장 가능한 라우팅 구성을 위해 사용한다. |
| State management | `Provider` | MVP 단계에서는 단순성과 유지보수성을 우선해 Riverpod보다 진입 장벽이 낮은 Provider를 선택한다. |
| Local storage | `shared_preferences` | 최근 URL처럼 작은 로컬 데이터를 저장하는 용도로 사용한다. |
| Backend | 사용하지 않음 | MVP는 서버 없이 동작한다. |
| DB | 사용하지 않음 | 핵심 데이터는 NFC 태그에 저장하고, 앱 내부 DB는 두지 않는다. |

Provider는 MVP의 단순한 상태 흐름에 충분하며, 라우팅/입력/미리보기/결과 화면 간 상태 공유를 과도한 구조 없이 구현할 수 있다. 상태가 복잡해지거나 테스트 경계가 커지면 이후 Riverpod 전환을 검토한다.

## 4. Core Features

### 4.1 Link Type Selection

- 사용자는 저장할 링크 유형을 선택한다.
- 선택지는 Instagram, LinkedIn, GitHub, Linktree, Portfolio, 직접 입력이다.
- 선택한 유형에 따라 입력 화면과 URL 생성/검증 규칙이 달라진다.

### 4.2 Instagram URL Generation

- 사용자는 Instagram 계정명만 입력한다.
- 입력값의 앞뒤 공백을 제거한다.
- 계정명 앞의 `@` 문자는 제거한다.
- 최종 URL은 `https://instagram.com/{username}` 형식으로 자동 생성한다.

### 4.3 Custom URL Input

- LinkedIn, GitHub, Linktree, Portfolio, 직접 URL은 전체 URL을 입력한다.
- `https://`가 없으면 자동으로 추가한다.
- 허용 스킴은 `http://` 또는 `https://`로 제한한다.
- URL 형식을 검사하고, 유효하지 않으면 저장 및 NFC 쓰기를 막는다.

### 4.4 Tracking Parameter Cleanup

- 사용자가 원할 경우 다음 query parameter를 제거한다.
  - `utm_source`
  - `utm_medium`
  - `utm_campaign`
  - `igsh`
- 긴 URL은 태그 용량 초과 가능성이 있으므로 tracking parameter 제거를 권장한다.

### 4.5 URL Preview

- 최종 URL을 쓰기 전에 확인한다.
- 링크 유형을 표시한다.
- 예상 byte를 표시한다.
- NTAG213 기준 144 byte 중 사용량을 표시한다.
- 저장 가능 여부를 표시한다.
- 사용자는 URL 열기, 수정, NFC 태그에 쓰기를 선택할 수 있다.

### 4.6 NFC Write

- 앱은 NFC 태그를 감지한다.
- 감지한 태그가 NDEF 쓰기를 지원하면 URL Record를 쓴다.
- 성공/실패 결과를 사용자에게 명확히 표시한다.

### 4.7 NFC Verify

- 쓰기 완료 후 같은 태그를 다시 읽는다.
- `expectedUrl`과 `actualUrl`을 비교한다.
- 일치/불일치 결과를 표시한다.
- 불일치 시 다시 쓰기 또는 URL 수정으로 복구할 수 있게 한다.

### 4.8 NFC Read

- 기존 NFC 태그에 저장된 URL을 읽는다.
- 읽은 URL을 화면에 표시한다.
- 사용자는 URL 열기, URL 복사, 다시 쓰기를 선택할 수 있다.

### 4.9 Tag Check

- 태그의 NDEF 지원 여부를 확인한다.
- 쓰기 가능 여부를 확인한다.
- `maxSize`를 확인한다.
- `readOnly` 여부를 확인한다.
- 현재 URL 저장에 적합한 태그인지 판단한다.

## 5. Key User Flows

### Instagram 저장 흐름

앱 실행 → Home → NFC 태그 만들기 → Link Type Select → Instagram 선택 → 계정명 입력 → `https://instagram.com/{계정명}` 자동 생성 → URL Preview → NFC 태그에 쓰기 → 쓰기 완료 → 다시 읽어서 검증 → URL 열기 테스트

### 기타 URL 저장 흐름

앱 실행 → Home → NFC 태그 만들기 → Link Type Select → LinkedIn/GitHub/Linktree/Portfolio/직접 입력 선택 → URL 전체 입력 → `https://` 없으면 자동 추가 → URL 형식 검사 → URL Preview → NFC 태그에 쓰기 → 쓰기 완료 → 다시 읽어서 검증 → URL 열기 테스트

### NFC 읽기 흐름

앱 실행 → Home → NFC 태그 읽기 → 태그 스캔 → 저장된 URL 표시 → URL 열기 또는 복사

### 태그 상태 확인 흐름

앱 실행 → Home → 태그 상태 확인 → 태그 스캔 → NDEF 지원 여부, 쓰기 가능 여부, 용량 확인 → URL 저장 가능 여부 표시

## 6. Main Screens

| 화면 | 역할 |
| --- | --- |
| `HomeScreen` | NFC 태그 만들기, NFC 태그 읽기, 태그 상태 확인으로 진입하는 홈 화면 |
| `LinkTypeSelectScreen` | 저장할 링크 유형을 선택하는 화면 |
| `InstagramInputScreen` | Instagram 계정명을 입력하고 Instagram URL을 자동 생성하는 화면 |
| `CustomUrlInputScreen` | LinkedIn, GitHub, Linktree, Portfolio, 직접 URL을 입력하고 정규화하는 화면 |
| `UrlPreviewScreen` | 최종 URL, 링크 유형, 예상 byte, 저장 가능 여부를 확인하는 화면 |
| `NfcWriteScreen` | NFC 태그 감지와 NDEF URL Record 쓰기를 진행하는 화면 |
| `WriteResultScreen` | NFC 쓰기 성공/실패 결과와 다음 행동을 안내하는 화면 |
| `VerifyScreen` | 쓰기 후 태그를 다시 읽어 expectedUrl과 actualUrl 일치 여부를 확인하는 화면 |
| `NfcReadScreen` | 기존 NFC 태그에 저장된 URL을 읽고 열기/복사/다시 쓰기 액션을 제공하는 화면 |
| `TagCheckScreen` | 태그의 NDEF 지원, 쓰기 가능 여부, 용량, readOnly 상태를 확인하는 화면 |

## 7. Data Strategy

- 핵심 데이터는 서버나 DB가 아니라 NFC 태그 내부에 저장한다.
- NFC 태그에는 NDEF URL Record 형태로 URL만 저장한다.
- 앱 내부에는 최근 입력 URL 정도만 `shared_preferences`로 저장한다.
- 사용자의 계정 정보, 로그인 정보, 프로필 데이터는 서버에 저장하지 않는다.
- MVP에서는 개인정보 저장을 최소화한다.
- 최근 URL 저장은 사용자 편의를 위한 보조 기능이며, 앱의 핵심 저장소로 취급하지 않는다.

## 8. NFC Capacity Policy

- 기준 태그는 NTAG213이다.
- 사용자 저장 가능 용량 기준은 144 byte로 둔다.
- MVP에서는 정확한 NFC 바이너리 계산이 아니라 보수적 추정을 사용한다.
- 계산 기준은 `URL UTF-8 byte + NDEF 헤더 예상값`이다.
- 144 byte를 초과하면 저장 불가 안내를 표시한다.
- 긴 URL은 tracking parameter 제거를 권장한다.
- 용량 계산은 사용자가 쓰기 전에 실패 가능성을 예측하기 위한 UX 장치이며, 실제 쓰기 결과와 다를 수 있음을 고려한다.

## 9. Error Handling Policy

NFC 실패 상황은 개발자 중심 오류가 아니라 사용자 친화적 메시지와 복구 행동으로 매핑한다.

| 상황 | 사용자 메시지 방향 | 복구 행동 |
| --- | --- | --- |
| NFC 미지원 | 이 기기는 NFC 기능을 지원하지 않는다고 안내 | NFC 지원 기기 사용 안내 |
| NFC 꺼짐 | NFC가 꺼져 있어 태그를 사용할 수 없다고 안내 | 설정에서 NFC 켜기 안내 |
| 태그 미감지 | 태그를 찾지 못했다고 안내 | 태그를 기기 가까이에 다시 대도록 안내 |
| NDEF 미지원 태그 | 이 태그는 URL 저장 형식을 지원하지 않는다고 안내 | 다른 NFC 태그 사용 안내 |
| 읽기 전용 태그 | 이 태그는 수정할 수 없다고 안내 | 쓰기 가능한 태그 사용 안내 |
| 용량 부족 | URL이 태그 용량보다 크다고 안내 | URL 줄이기 또는 tracking parameter 제거 안내 |
| 쓰기 실패 | URL 저장에 실패했다고 안내 | 다시 시도 또는 태그 교체 안내 |
| 읽기 실패 | 태그 내용을 읽지 못했다고 안내 | 다시 스캔 안내 |
| 세션 취소 | NFC 작업이 취소되었다고 안내 | 필요하면 다시 시작 안내 |
| 알 수 없는 오류 | 알 수 없는 문제가 발생했다고 안내 | 재시도 및 문제 지속 시 기록 확인 안내 |

## 10. Design Direction

- 밝은 배경을 사용한다.
- 흰색 카드형 UI를 중심으로 구성한다.
- 둥근 모서리를 사용한다.
- 부드러운 그림자를 사용한다.
- 딥 네이비 또는 블랙 계열을 메인 컬러로 사용한다.
- 한국어 UI를 기본으로 한다.
- 큰 제목, 짧은 설명, 명확한 CTA 버튼을 사용한다.
- iOS 스타일에 가까운 깔끔한 모바일 UI를 지향한다.
- 구체적인 스타일 기준은 `docs/design-system.md`와 `docs/mockup-guide.md`를 따른다.

## 11. Development Roadmap

1. 프로젝트 기본 구조 생성
2. 라우팅 구성
3. 공통 테마 구성
4. LinkType 모델 및 URL 정규화 유틸 구현
5. HomeScreen 구현
6. LinkTypeSelectScreen 구현
7. InstagramInputScreen 구현
8. CustomUrlInputScreen 구현
9. UrlPreviewScreen 구현
10. NdefSizeCalculator 구현
11. NfcService POC 구현
12. NfcReadScreen 구현
13. NfcWriteScreen 구현
14. WriteResultScreen 구현
15. VerifyScreen 구현
16. TagCheckScreen 구현
17. 에러 처리 공통 컴포넌트 구현
18. 최근 URL 로컬 저장 구현
19. Android/iOS 실기기 테스트

## 12. First Implementation Scope

### 1차 구현 범위

- 폴더 구조 정리
- `go_router` 라우팅 구성
- 공통 테마 생성
- `LinkType` 모델 생성
- `LinkInputMode` 모델 생성
- `UrlDraft` 모델 생성
- `UrlNormalizer` 생성
- `NdefSizeCalculator` 생성
- `HomeScreen`
- `LinkTypeSelectScreen`
- `InstagramInputScreen`
- `CustomUrlInputScreen`
- `UrlPreviewScreen`

### 1차 구현에서 제외

- 실제 NFC 읽기
- 실제 NFC 쓰기
- `nfc_manager` 기반 `NfcService` 실제 구현
- Android/iOS 네이티브 설정
- 실기기 테스트
