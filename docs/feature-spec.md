# NFC Link Manager 기능명세

이 문서는 NFC Link Manager MVP의 Flutter 화면, 모델, 유틸, NFC 서비스 구현 기준을 정의한다. 기획 범위는 `docs/planning.md`, 화면 전환과 분기는 `docs/user-flow.md`를 따른다.

## 1. Screen Specification

### HomeScreen

- 역할
  - 앱의 메인 진입 화면이다.
  - NFC 태그 만들기, NFC 태그 읽기, 태그 상태 확인으로 이동한다.
- 진입 경로
  - 앱 실행 시 기본 진입 화면.
  - 다른 화면에서 홈으로 이동 액션 선택 시 진입.
- 주요 UI 요소
  - 앱 이름: `NFC Link Manager`
  - 메인 문구: `NFC 태그에 원하는 링크를 저장하세요`
  - 설명 문구: Instagram, LinkedIn, GitHub, Linktree, Portfolio, 직접 URL을 NFC 태그에 저장할 수 있음을 안내.
  - 액션 카드: `NFC 태그 만들기`, `NFC 태그 읽기`, `태그 상태 확인`
- 사용자 입력
  - 별도 텍스트 입력 없음.
  - 액션 카드 선택.
- 주요 동작
  - NFC 태그 만들기 선택 시 링크 유형 선택 흐름 시작.
  - NFC 태그 읽기 선택 시 태그 읽기 흐름 시작.
  - 태그 상태 확인 선택 시 태그 검사 흐름 시작.
- 다음 화면
  - `NFC 태그 만들기` → `LinkTypeSelectScreen`
  - `NFC 태그 읽기` → `NfcReadScreen`
  - `태그 상태 확인` → `TagCheckScreen`
- 예외 상황
  - NFC 미지원이 사전에 확인되면 NFC 관련 액션에 경고 상태를 표시할 수 있다.
  - NFC 지원 여부를 아직 확인하지 못한 경우 각 NFC 화면 진입 후 확인한다.

### LinkTypeSelectScreen

- 역할
  - NFC 태그에 저장할 링크 유형을 선택한다.
- 진입 경로
  - `HomeScreen`에서 `NFC 태그 만들기` 선택.
- 주요 UI 요소
  - 화면 제목: `어떤 링크를 저장할까요?`
  - 링크 유형 선택 카드 또는 리스트.
  - 선택지: Instagram, LinkedIn, GitHub, Linktree, Portfolio, 직접 입력
- 사용자 입력
  - 링크 유형 하나 선택.
- 주요 동작
  - 선택한 링크 유형에 따라 입력 화면을 분기한다.
  - 선택한 `LinkType`을 다음 화면으로 전달한다.
- 다음 화면
  - Instagram 선택 → `InstagramInputScreen`
  - LinkedIn/GitHub/Linktree/Portfolio/직접 입력 선택 → `CustomUrlInputScreen`
- 예외 상황
  - 선택 없이 다음으로 이동할 수 없다.
  - 알 수 없는 `LinkType`이 전달되면 `HomeScreen`으로 복귀하거나 오류 메시지를 표시한다.

### InstagramInputScreen

- 역할
  - Instagram 계정명만 입력받아 NFC에 저장할 Instagram URL을 생성한다.
- 진입 경로
  - `LinkTypeSelectScreen`에서 Instagram 선택.
  - `UrlPreviewScreen` 또는 `VerifyScreen`에서 URL 수정 선택 후 Instagram 유형으로 복귀.
- 주요 UI 요소
  - 계정명 입력 필드.
  - 예시 텍스트: `@romrom_official`
  - 생성될 URL 미리보기.
  - 다음 버튼.
- 사용자 입력
  - Instagram 계정명.
- 주요 동작
  - 입력값 앞뒤 공백 제거.
  - 계정명 앞의 `@` 제거.
  - 빈 값 방지.
  - `https://instagram.com/{username}` 형식으로 변환.
  - `UrlDraft` 생성.
  - 예상 byte와 저장 가능 여부 계산.
- 다음 화면
  - 유효한 계정명 입력 후 다음 선택 → `UrlPreviewScreen`
- 예외 상황
  - 입력값이 비어 있으면 같은 화면에 머물고 입력 필요 메시지를 표시한다.
  - 정규화 후 URL이 유효하지 않으면 다음 화면으로 이동하지 않는다.
  - 예상 용량 초과 자체는 입력 화면에서 막지 않고 `UrlPreviewScreen`에서 명확히 안내한다.
- 예시
  - 입력: `@romrom_official`
  - 결과: `https://instagram.com/romrom_official`

### CustomUrlInputScreen

- 역할
  - LinkedIn, GitHub, Linktree, Portfolio, 직접 URL을 전체 URL 입력 방식으로 받는다.
- 진입 경로
  - `LinkTypeSelectScreen`에서 Instagram 외 링크 유형 선택.
  - `UrlPreviewScreen`, `VerifyScreen`, `NfcReadScreen`에서 URL 수정 또는 다시 쓰기 선택.
- 주요 UI 요소
  - URL 입력 필드.
  - 선택된 링크 유형 표시.
  - tracking parameter 제거 옵션.
  - 정규화된 URL 미리보기.
  - 다음 버튼.
- 사용자 입력
  - 전체 URL 또는 도메인부터 시작하는 URL.
  - tracking parameter 제거 여부.
- 주요 동작
  - 입력값 앞뒤 공백 제거.
  - `https://`가 없으면 자동 추가.
  - `http://` 또는 `https://`만 허용.
  - URL 형식 검사.
  - tracking parameter 제거 옵션 제공.
  - 제거 대상 query parameter: `utm_source`, `utm_medium`, `utm_campaign`, `igsh`
  - `UrlDraft` 생성.
  - 예상 byte와 저장 가능 여부 계산.
- 다음 화면
  - 유효한 URL 입력 후 다음 선택 → `UrlPreviewScreen`
- 예외 상황
  - 입력값이 비어 있으면 같은 화면에 머물고 입력 필요 메시지를 표시한다.
  - 허용하지 않는 스킴이면 오류 메시지를 표시한다.
  - URL 형식이 유효하지 않으면 다음 화면으로 이동하지 않는다.
  - tracking parameter 제거 후에도 URL이 유효해야 한다.
- 예시
  - 입력: `github.com/romrom`
  - 결과: `https://github.com/romrom`

### UrlPreviewScreen

- 역할
  - NFC 태그에 저장할 최종 URL을 확인한다.
- 진입 경로
  - `InstagramInputScreen`에서 유효한 계정명 제출.
  - `CustomUrlInputScreen`에서 유효한 URL 제출.
  - `NfcReadScreen`에서 다시 쓰기 선택 후 읽은 URL을 기반으로 진입할 수 있다.
- 주요 UI 요소
  - 링크 유형.
  - 최종 URL.
  - 예상 byte.
  - NTAG213 기준 144 byte 중 사용량.
  - 저장 가능 여부.
  - URL 열기 버튼.
  - 수정 버튼.
  - NFC 태그에 쓰기 버튼.
- 사용자 입력
  - URL 열기, 수정, NFC 태그에 쓰기 중 선택.
- 주요 동작
  - 최종 URL을 사용자에게 명확히 보여준다.
  - `NdefSizeCalculator` 기준 예상 byte를 표시한다.
  - `canStoreInNtag213` 결과에 따라 쓰기 버튼 활성/비활성 상태를 결정한다.
- 다음 화면
  - URL 열기 → 외부 브라우저 또는 인앱 브라우저.
  - 수정 → `InstagramInputScreen` 또는 `CustomUrlInputScreen`
  - NFC 태그에 쓰기 → `NfcWriteScreen`
- 예외 상황
  - 용량 초과 시 `NfcWriteScreen`으로 이동하지 않는다.
  - URL이 유효하지 않은 상태로 진입하면 이전 입력 화면으로 돌려보내거나 오류 상태를 표시한다.

### NfcWriteScreen

- 역할
  - NFC 태그에 URL을 NDEF URL Record로 쓴다.
- 진입 경로
  - `UrlPreviewScreen`에서 `NFC 태그에 쓰기` 선택.
  - `WriteResultScreen` 또는 `VerifyScreen`에서 다시 쓰기 선택.
- 주요 UI 요소
  - 안내 문구: `휴대폰 뒷면을 NFC 태그에 가까이 대세요`
  - 저장할 URL 표시.
  - 태그 대기 중 상태 표시.
  - 취소 버튼.
- 사용자 입력
  - NFC 태그를 기기에 가까이 댐.
  - 취소 버튼 선택.
- 주요 동작
  - NFC 사용 가능 여부 확인.
  - NFC 태그 감지.
  - NDEF 지원 여부와 쓰기 가능 여부 확인.
  - NDEF URL Record 쓰기.
  - 성공/실패 결과 생성.
- 다음 화면
  - 쓰기 성공 → `WriteResultScreen`
  - 쓰기 실패 → 현재 화면에 에러 표시 또는 실패 상태의 `WriteResultScreen`
  - 취소 → `UrlPreviewScreen` 또는 이전 화면
- 예외 상황
  - NFC 미지원.
  - NFC 꺼짐.
  - 태그 미감지.
  - NDEF 미지원 태그.
  - 읽기 전용 태그.
  - 용량 부족.
  - 쓰기 실패.
  - 세션 취소.
  - 알 수 없는 오류.

### WriteResultScreen

- 역할
  - NFC 쓰기 결과를 표시한다.
- 진입 경로
  - `NfcWriteScreen`에서 쓰기 완료 또는 실패.
- 주요 UI 요소
  - 결과 상태: 성공 또는 실패.
  - 성공 시 저장한 URL.
  - 성공 시 검증하기 버튼.
  - 성공 시 홈으로 이동 버튼.
  - 실패 시 실패 원인.
  - 실패 시 다시 시도 버튼.
- 사용자 입력
  - 검증하기.
  - 홈으로 이동.
  - 다시 시도.
- 주요 동작
  - `NfcWriteResult`를 사용자 메시지로 변환해 보여준다.
  - 성공 시 검증 흐름으로 진입할 수 있게 한다.
  - 실패 시 같은 URL로 다시 쓰기를 시도할 수 있게 한다.
- 다음 화면
  - 검증하기 → `VerifyScreen`
  - 다시 시도 → `NfcWriteScreen`
  - 홈으로 이동 → `HomeScreen`
- 예외 상황
  - 실패 원인이 없으면 알 수 없는 오류로 표시한다.
  - 저장 URL이 비어 있으면 홈 이동만 제공한다.

### VerifyScreen

- 역할
  - 쓰기 후 같은 태그를 다시 읽어서 저장값을 검증한다.
- 진입 경로
  - `WriteResultScreen`에서 검증하기 선택.
- 주요 UI 요소
  - 검증 안내 문구.
  - expectedUrl 표시.
  - actualUrl 표시.
  - 일치/불일치 결과.
  - 다시 스캔, 다시 쓰기, URL 수정, URL 열기, 홈으로 이동 버튼.
- 사용자 입력
  - 같은 NFC 태그 다시 스캔.
  - 결과에 따른 액션 선택.
- 주요 동작
  - 태그 다시 읽기.
  - NDEF URL Record에서 `actualUrl` 추출.
  - `expectedUrl`과 `actualUrl` 비교.
  - 같으면 성공.
  - 다르면 불일치 표시.
- 다음 화면
  - 검증 성공 후 URL 열기 → 외부 브라우저 또는 인앱 브라우저.
  - 다시 쓰기 → `NfcWriteScreen`
  - URL 수정 → `InstagramInputScreen` 또는 `CustomUrlInputScreen`
  - 홈으로 이동 → `HomeScreen`
- 예외 상황
  - 읽기 실패.
  - 태그 미감지.
  - URL Record 없음.
  - 불일치.
  - 세션 취소.

### NfcReadScreen

- 역할
  - 기존 NFC 태그에 저장된 URL을 읽는다.
- 진입 경로
  - `HomeScreen`에서 `NFC 태그 읽기` 선택.
- 주요 UI 요소
  - 태그 스캔 대기 상태.
  - 저장된 URL.
  - 태그 타입.
  - 쓰기 가능 여부.
  - 최대 용량.
  - URL 열기 버튼.
  - URL 복사 버튼.
  - 다시 쓰기 버튼.
- 사용자 입력
  - NFC 태그를 기기에 가까이 댐.
  - URL 열기, URL 복사, 다시 쓰기 선택.
- 주요 동작
  - NFC 태그 감지.
  - NDEF URL Record 읽기.
  - 태그 메타데이터 표시.
  - 읽은 URL을 후속 액션에 전달.
- 다음 화면
  - URL 열기 → 외부 브라우저 또는 인앱 브라우저.
  - URL 복사 → 같은 화면 유지.
  - 다시 쓰기 → `UrlPreviewScreen` 또는 `CustomUrlInputScreen`
- 예외 상황
  - NFC 미지원.
  - NFC 꺼짐.
  - 태그 미감지.
  - NDEF 미지원 태그.
  - URL Record 없음.
  - 읽기 실패.
  - 세션 취소.

### TagCheckScreen

- 역할
  - 태그가 URL 저장에 적합한지 확인한다.
- 진입 경로
  - `HomeScreen`에서 `태그 상태 확인` 선택.
- 주요 UI 요소
  - 태그 스캔 대기 상태.
  - NDEF 지원 여부.
  - 쓰기 가능 여부.
  - `maxSize`.
  - `readOnly` 여부.
  - 저장 가능 여부.
  - 다시 스캔 버튼.
  - 홈으로 이동 버튼.
- 사용자 입력
  - NFC 태그를 기기에 가까이 댐.
  - 다시 스캔 또는 홈으로 이동 선택.
- 주요 동작
  - NFC 태그 감지.
  - NDEF 지원 여부 확인.
  - 쓰기 가능 여부 확인.
  - `maxSize` 확인.
  - `readOnly` 여부 확인.
  - NTAG213 144 byte 기준 URL 저장 가능 여부 표시.
- 다음 화면
  - 다시 스캔 → `TagCheckScreen`
  - 홈으로 이동 → `HomeScreen`
- 예외 상황
  - NFC 미지원.
  - NFC 꺼짐.
  - 태그 미감지.
  - NDEF 미지원 태그.
  - 읽기 실패.
  - 알 수 없는 오류.

## 2. Data Models

### LinkType

- 목적
  - 사용자가 선택 가능한 링크 유형과 입력 방식을 정의한다.
- 필드
  - `id`
  - `label`
  - `inputMode`
  - `baseUrl`
  - `placeholder`
  - `description`
  - `iconName`
- 필드 타입 제안
  - `id`: `String`
  - `label`: `String`
  - `inputMode`: `LinkInputMode`
  - `baseUrl`: `String?`
  - `placeholder`: `String`
  - `description`: `String`
  - `iconName`: `String`
- 사용 화면 또는 사용 위치
  - `LinkTypeSelectScreen`
  - `InstagramInputScreen`
  - `CustomUrlInputScreen`
  - `UrlPreviewScreen`
  - URL 정규화 분기

### LinkInputMode

- 목적
  - 링크 유형별 입력 방식을 구분한다.
- 값
  - `username`: 계정명만 입력받는 방식. MVP에서는 Instagram에 사용.
  - `fullUrl`: 전체 URL 입력 방식. LinkedIn, GitHub, Linktree, Portfolio, 직접 입력에 사용.
- 필드 타입 제안
  - Dart enum: `enum LinkInputMode { username, fullUrl }`
- 사용 화면 또는 사용 위치
  - `LinkTypeSelectScreen` 이후 입력 화면 분기.
  - `UrlNormalizer` 호출 분기.

### UrlDraft

- 목적
  - 사용자가 입력한 원본 값, 정규화된 URL, 용량 추정 결과, 유효성 상태를 함께 전달한다.
- 필드
  - `linkType`
  - `originalInput`
  - `normalizedUrl`
  - `estimatedBytes`
  - `isValid`
- 필드 타입 제안
  - `linkType`: `LinkType`
  - `originalInput`: `String`
  - `normalizedUrl`: `String`
  - `estimatedBytes`: `int`
  - `isValid`: `bool`
- 사용 화면 또는 사용 위치
  - `InstagramInputScreen`
  - `CustomUrlInputScreen`
  - `UrlPreviewScreen`
  - `NfcWriteScreen`
  - `VerifyScreen`

### NfcTagInfo

- 목적
  - 감지한 NFC 태그의 저장 가능성과 상태를 표현한다.
- 필드
  - `tagId`
  - `ndefAvailable`
  - `isWritable`
  - `maxSize`
  - `currentSize`
  - `isReadOnly`
- 필드 타입 제안
  - `tagId`: `String?`
  - `ndefAvailable`: `bool`
  - `isWritable`: `bool`
  - `maxSize`: `int?`
  - `currentSize`: `int?`
  - `isReadOnly`: `bool`
- 사용 화면 또는 사용 위치
  - `NfcReadScreen`
  - `NfcWriteScreen`
  - `TagCheckScreen`
  - `NfcService.checkTag()`

### NfcWriteResult

- 목적
  - NFC URL 쓰기 결과를 화면과 검증 흐름에 전달한다.
- 필드
  - `success`
  - `url`
  - `errorCode`
  - `errorMessage`
- 필드 타입 제안
  - `success`: `bool`
  - `url`: `String?`
  - `errorCode`: `String?`
  - `errorMessage`: `String?`
- 사용 화면 또는 사용 위치
  - `NfcWriteScreen`
  - `WriteResultScreen`
  - `VerifyScreen`

### NfcVerifyResult

- 목적
  - 쓰기 후 검증 결과를 표현한다.
- 필드
  - `expectedUrl`
  - `actualUrl`
  - `isMatched`
- 필드 타입 제안
  - `expectedUrl`: `String`
  - `actualUrl`: `String?`
  - `isMatched`: `bool`
- 사용 화면 또는 사용 위치
  - `VerifyScreen`
  - `WriteResultScreen` 이후 검증 결과 처리.

### NfcError

- 목적
  - NFC 및 URL 처리 오류를 사용자 메시지와 복구 액션으로 매핑한다.
- 필드
  - `code`
  - `title`
  - `description`
  - `actionLabel`
- 필드 타입 제안
  - `code`: `String`
  - `title`: `String`
  - `description`: `String`
  - `actionLabel`: `String`
- 사용 화면 또는 사용 위치
  - `NfcWriteScreen`
  - `WriteResultScreen`
  - `VerifyScreen`
  - `NfcReadScreen`
  - `TagCheckScreen`
  - 공통 에러 컴포넌트

## 3. Utility Specification

### UrlNormalizer

#### `normalizeInstagramUsername(String input)`

- 입력
  - 사용자가 입력한 Instagram 계정명 문자열.
- 출력
  - `https://instagram.com/{username}` 형식의 URL 문자열.
- 처리 규칙
  - 앞뒤 공백 제거.
  - 시작 문자가 `@`이면 제거.
  - 제거 후 빈 값이면 실패 처리.
  - username 내부 공백은 허용하지 않는다.
  - 최종 URL을 `isValidHttpUrl`로 검증한다.
- 예시
  - 입력: ` @romrom_official `
  - 출력: `https://instagram.com/romrom_official`
- 실패 케이스
  - 빈 문자열.
  - `@`만 입력.
  - 공백이 포함된 계정명.
  - URL로 변환 후 유효하지 않은 값.

#### `normalizeFullUrl(String input)`

- 입력
  - 사용자가 입력한 전체 URL 또는 도메인부터 시작하는 URL.
- 출력
  - `http://` 또는 `https://` 스킴을 가진 정규화 URL 문자열.
- 처리 규칙
  - 앞뒤 공백 제거.
  - 스킴이 없으면 `https://`를 추가.
  - `http://` 또는 `https://`만 허용.
  - URL 형식을 검사한다.
  - path, query, fragment는 보존한다.
- 예시
  - 입력: `github.com/romrom`
  - 출력: `https://github.com/romrom`
- 실패 케이스
  - 빈 문자열.
  - `mailto:hello@example.com`
  - `tel:01012345678`
  - 호스트가 없는 문자열.
  - 파싱할 수 없는 URL.

#### `removeTrackingParams(String url)`

- 입력
  - 정규화된 URL 문자열.
- 출력
  - tracking parameter가 제거된 URL 문자열.
- 처리 규칙
  - URL query parameter 중 다음 키를 제거한다.
    - `utm_source`
    - `utm_medium`
    - `utm_campaign`
    - `igsh`
  - 제거 대상이 아닌 query parameter는 보존한다.
  - fragment는 보존한다.
  - 제거 후에도 `isValidHttpUrl`을 통과해야 한다.
- 예시
  - 입력: `https://example.com/profile?utm_source=ig&id=123&igsh=abc`
  - 출력: `https://example.com/profile?id=123`
- 실패 케이스
  - 입력 URL이 유효하지 않음.
  - 제거 후 URL 파싱 실패.

#### `isValidHttpUrl(String url)`

- 입력
  - URL 문자열.
- 출력
  - 유효한 HTTP(S) URL이면 `true`, 아니면 `false`.
- 처리 규칙
  - 스킴은 `http` 또는 `https`만 허용.
  - host가 있어야 한다.
  - 공백만 있는 문자열은 허용하지 않는다.
  - MVP에서는 네트워크 요청으로 실제 존재 여부를 검사하지 않는다.
- 예시
  - `https://github.com/romrom` → `true`
  - `github.com/romrom` → `false` (`normalizeFullUrl` 전 기준)
  - `mailto:hello@example.com` → `false`
- 실패 케이스
  - 빈 문자열.
  - host 없음.
  - 허용하지 않는 스킴.
  - 파싱 불가능한 문자열.

### NdefSizeCalculator

- 목적
  - URL이 NTAG213 기준 사용자 저장 가능 용량에 들어가는지 쓰기 전에 예측한다.
- 상수
  - `maxBytes = 144`
- 함수
  - `estimateUrlRecordBytes(String url)`
    - 입력: 정규화된 URL.
    - 출력: 예상 NDEF URL Record byte 수.
    - 정책: URL UTF-8 byte + NDEF 헤더 예상값을 더한다.
  - `canStoreInNtag213(String url)`
    - 입력: 정규화된 URL.
    - 출력: `estimateUrlRecordBytes(url) <= 144`이면 `true`.
- 정책
  - MVP에서는 정확한 NFC 바이너리 계산 대신 보수적 추정을 사용한다.
  - URL UTF-8 byte + NDEF 헤더 예상값을 더해서 계산한다.
  - NTAG213 사용자 용량 144 byte 기준으로 저장 가능 여부를 판단한다.
  - 용량 초과 시 `UrlPreviewScreen`에서 쓰기 버튼을 비활성화한다.
  - 긴 URL은 tracking parameter 제거를 우선 권장한다.

### NfcService

이번 문서에서는 인터페이스 명세만 정의한다. 실제 `nfc_manager` 기반 구현, Android/iOS 네이티브 설정, 실기기 검증은 다음 개발 단계에서 진행한다.

#### `isAvailable()`

- 목적: 현재 기기에서 NFC 사용 가능 여부를 확인한다.
- 입력: 없음.
- 출력 제안: `Future<bool>`
- 사용 위치: `HomeScreen`, NFC 관련 화면 진입 전 또는 세션 시작 전.

#### `readTag()`

- 목적: NFC 태그를 읽고 URL 및 태그 정보를 반환한다.
- 입력: 없음.
- 출력 제안: `Future<ReadTagResult>`
- 사용 위치: `NfcReadScreen`, `VerifyScreen`
- 비고: 실제 모델명은 구현 시 확정하되, URL 문자열과 `NfcTagInfo`를 포함해야 한다.

#### `writeUrl(String url)`

- 목적: 정규화된 URL을 NDEF URL Record로 NFC 태그에 쓴다.
- 입력: 정규화되고 용량 검사를 통과한 URL.
- 출력 제안: `Future<NfcWriteResult>`
- 사용 위치: `NfcWriteScreen`

#### `checkTag()`

- 목적: 태그의 NDEF 지원, 쓰기 가능 여부, 용량, readOnly 상태를 확인한다.
- 입력: 없음.
- 출력 제안: `Future<NfcTagInfo>`
- 사용 위치: `TagCheckScreen`, `NfcWriteScreen`

#### `stopSession()`

- 목적: 진행 중인 NFC 세션을 취소하거나 종료한다.
- 입력: 없음 또는 사용자 메시지.
- 출력 제안: `Future<void>`
- 사용 위치: `NfcWriteScreen`, `NfcReadScreen`, `VerifyScreen`, `TagCheckScreen`

## 4. Error Handling Specification

| Error Case | Possible Cause | User Message Direction | Recommended Action | Related Screen |
| --- | --- | --- | --- | --- |
| NFC 미지원 | 기기에 NFC 하드웨어가 없거나 OS에서 지원하지 않음 | 이 기기는 NFC 기능을 지원하지 않는다고 안내 | NFC 지원 기기 사용 안내, 홈으로 이동 | `HomeScreen`, `NfcWriteScreen`, `NfcReadScreen`, `VerifyScreen`, `TagCheckScreen` |
| NFC 꺼짐 | Android 설정에서 NFC가 비활성화됨 | NFC가 꺼져 있어 태그를 사용할 수 없다고 안내 | 설정에서 NFC 켜기, 다시 시도 | `NfcWriteScreen`, `NfcReadScreen`, `VerifyScreen`, `TagCheckScreen` |
| 태그 미감지 | 태그와 기기 거리가 멀거나 스캔 시간이 초과됨 | 태그를 찾지 못했으니 휴대폰 뒷면에 다시 가까이 대라고 안내 | 다시 스캔, 취소 | `NfcWriteScreen`, `NfcReadScreen`, `VerifyScreen`, `TagCheckScreen` |
| NDEF 미지원 태그 | 감지한 태그가 NDEF를 지원하지 않음 | 이 태그는 URL 저장 형식을 지원하지 않는다고 안내 | 다른 NFC 태그 사용, 다시 스캔 | `NfcWriteScreen`, `NfcReadScreen`, `TagCheckScreen` |
| 읽기 전용 태그 | 태그가 readOnly이거나 잠겨 있음 | 이 태그는 읽기 전용이라 수정할 수 없다고 안내 | 쓰기 가능한 태그 사용, 태그 읽기만 진행 | `NfcWriteScreen`, `TagCheckScreen` |
| 용량 부족 | URL 예상 byte 또는 실제 NDEF payload가 태그 용량 초과 | URL이 태그 용량보다 커서 저장할 수 없다고 안내 | URL 수정, tracking parameter 제거, 더 큰 태그 사용 | `UrlPreviewScreen`, `NfcWriteScreen`, `TagCheckScreen` |
| 쓰기 실패 | NDEF 쓰기 중 오류, 태그 이동, OS 세션 실패 | URL 저장에 실패했다고 안내 | 다시 시도, 태그 교체, URL 수정 | `NfcWriteScreen`, `WriteResultScreen` |
| 읽기 실패 | NDEF 읽기 중 오류, 태그 이동, URL Record 없음 | 태그 내용을 읽지 못했다고 안내 | 다시 스캔, 취소, 홈으로 이동 | `NfcReadScreen`, `VerifyScreen` |
| 세션 취소 | 사용자가 취소했거나 시스템이 NFC 세션을 종료함 | NFC 작업이 취소되었다고 안내 | 다시 시작, 이전 화면으로 이동 | `NfcWriteScreen`, `NfcReadScreen`, `VerifyScreen`, `TagCheckScreen` |
| 알 수 없는 오류 | 분류되지 않은 예외 또는 플랫폼별 예상 외 응답 | 알 수 없는 문제가 발생했다고 안내 | 다시 시도, 홈으로 이동, 문제 지속 시 기록 확인 | 모든 화면 |

## 5. First Implementation Boundary

### 1차 구현에 포함

- 폴더 구조 정리.
- `go_router` 라우팅 구성.
- 공통 테마 생성.
- `LinkType` 모델 생성.
- `LinkInputMode` 모델 생성.
- `UrlDraft` 모델 생성.
- `UrlNormalizer` 생성.
- `NdefSizeCalculator` 생성.
- `HomeScreen`
- `LinkTypeSelectScreen`
- `InstagramInputScreen`
- `CustomUrlInputScreen`
- `UrlPreviewScreen`

### 1차 구현에서 제외

- 실제 NFC 읽기.
- 실제 NFC 쓰기.
- `nfc_manager` 기반 `NfcService` 실제 구현.
- Android/iOS 네이티브 설정.
- 실기기 테스트.

### 1차 구현 판단 기준

- 앱은 홈에서 링크 유형 선택, 입력, 정규화, URL 미리보기까지 이동할 수 있어야 한다.
- `UrlNormalizer`와 `NdefSizeCalculator`는 NFC 실제 구현 없이 단위 테스트 가능한 순수 로직이어야 한다.
- `UrlPreviewScreen`은 예상 byte와 NTAG213 144 byte 기준 저장 가능 여부를 표시해야 한다.
- NFC 관련 화면은 1차 구현에서 라우팅 대상이 아니거나 placeholder로만 남긴다.
