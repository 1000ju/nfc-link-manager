# NFC Link Manager 사용자 흐름

이 문서는 NFC Link Manager MVP의 화면 전환, 라우팅, 예외 흐름을 정리한다. 화면별 상세 UI 요구사항은 `docs/feature-spec.md`에서 다루고, 이 문서는 사용자가 어떤 행동을 했을 때 어느 화면으로 이동하는지와 주요 분기만 정의한다.

## 1. 전체 앱 진입 흐름

### 기본 진입

앱 실행 → `HomeScreen`

### HomeScreen 선택지

| 사용자 선택 | 이동 화면 | 목적 |
| --- | --- | --- |
| NFC 태그 만들기 | `LinkTypeSelectScreen` | NFC 태그에 저장할 링크 유형을 선택한다. |
| NFC 태그 읽기 | `NfcReadScreen` | 기존 NFC 태그에 저장된 NDEF URL Record를 읽는다. |
| 태그 상태 확인 | `TagCheckScreen` | 태그의 NDEF 지원, 쓰기 가능 여부, 용량, readOnly 상태를 확인한다. |

## 2. Instagram 저장 흐름

### 정상 흐름

1. 앱 실행
2. `HomeScreen`
3. 사용자가 `NFC 태그 만들기` 선택
4. `LinkTypeSelectScreen`
5. 사용자가 `Instagram` 선택
6. `InstagramInputScreen`
7. 사용자가 계정명 입력
8. 앱이 입력값 앞뒤 공백 제거
9. 앱이 계정명 앞의 `@` 제거
10. 앱이 `https://instagram.com/{username}` 형식의 URL 자동 생성
11. `UrlPreviewScreen`
12. 사용자가 최종 URL, 예상 byte, 저장 가능 여부 확인
13. 사용자가 `NFC 태그에 쓰기` 선택
14. `NfcWriteScreen`
15. NFC 태그 감지 후 NDEF URL Record 쓰기
16. `WriteResultScreen`
17. 사용자가 `검증하기` 선택
18. `VerifyScreen`
19. 같은 NFC 태그 다시 스캔
20. 앱이 `expectedUrl`과 `actualUrl` 비교
21. 일치하면 검증 성공 표시
22. 사용자가 URL 열기 테스트

### 주요 분기

- 계정명이 비어 있으면 `InstagramInputScreen`에 머물고 입력 필요 메시지를 표시한다.
- 정규화 후 URL이 유효하지 않으면 `UrlPreviewScreen`으로 이동하지 않는다.
- 예상 용량이 NTAG213 기준 144 byte를 초과하면 `UrlPreviewScreen`에서 쓰기 진입을 막고 URL 축소를 안내한다.
- 쓰기 실패 시 `WriteResultScreen`에서 다시 시도 또는 이전 화면으로 돌아가기를 제공한다.
- 검증 불일치 시 `VerifyScreen`에서 불일치 경고와 다시 쓰기 액션을 제공한다.

## 3. 기타 URL 저장 흐름

### 대상 링크 유형

- LinkedIn
- GitHub
- Linktree
- Portfolio
- 직접 입력

### 정상 흐름

1. 앱 실행
2. `HomeScreen`
3. 사용자가 `NFC 태그 만들기` 선택
4. `LinkTypeSelectScreen`
5. 사용자가 LinkedIn/GitHub/Linktree/Portfolio/직접 입력 중 하나 선택
6. `CustomUrlInputScreen`
7. 사용자가 URL 전체 입력
8. 앱이 입력값 앞뒤 공백 제거
9. `https://`가 없으면 앱이 자동 추가
10. 앱이 `http://` 또는 `https://` 스킴만 허용
11. 앱이 URL 형식 검사
12. 앱이 tracking parameter 제거 옵션 제공
13. 사용자가 옵션을 선택하면 `utm_source`, `utm_medium`, `utm_campaign`, `igsh` 제거
14. `UrlPreviewScreen`
15. 사용자가 최종 URL, 예상 byte, 저장 가능 여부 확인
16. 사용자가 `NFC 태그에 쓰기` 선택
17. `NfcWriteScreen`
18. NFC 태그 감지 후 NDEF URL Record 쓰기
19. `WriteResultScreen`
20. 사용자가 `검증하기` 선택
21. `VerifyScreen`
22. 같은 NFC 태그 다시 스캔
23. 앱이 `expectedUrl`과 `actualUrl` 비교
24. 사용자가 URL 열기 테스트

### 주요 분기

- URL이 비어 있으면 `CustomUrlInputScreen`에 머물고 URL 입력 필요 메시지를 표시한다.
- `mailto:`, `tel:`, 커스텀 스킴 등은 MVP에서 허용하지 않는다.
- URL 형식 검사를 통과하지 못하면 `UrlPreviewScreen`으로 이동하지 않는다.
- 예상 용량이 NTAG213 기준 144 byte를 초과하면 tracking parameter 제거 또는 짧은 URL 사용을 안내한다.
- tracking parameter 제거 후에도 원본 URL을 다시 수정할 수 있어야 한다.

## 4. NFC 읽기 흐름

### 정상 흐름

1. 앱 실행
2. `HomeScreen`
3. 사용자가 `NFC 태그 읽기` 선택
4. `NfcReadScreen`
5. 앱이 태그 스캔 대기 상태 표시
6. 사용자가 NFC 태그를 기기에 가까이 댐
7. 앱이 태그 감지
8. 앱이 NDEF URL Record 읽기
9. 앱이 저장된 URL 표시
10. 사용자가 `URL 열기` 선택 가능
11. 사용자가 `URL 복사` 선택 가능
12. 사용자가 `다시 쓰기` 선택 가능

### 다시 쓰기 분기

`NfcReadScreen`에서 `다시 쓰기` 선택 → 읽은 URL을 초기값으로 사용 → `UrlPreviewScreen` 또는 `CustomUrlInputScreen`으로 이동

### 주요 분기

- URL Record가 없으면 읽을 수 있는 URL이 없다는 메시지를 표시한다.
- URL 형식이 유효하지 않으면 열기 액션은 막고 복사 액션은 제공할 수 있다.
- 읽기 실패 시 재스캔 액션을 제공한다.

## 5. 태그 상태 확인 흐름

### 정상 흐름

1. 앱 실행
2. `HomeScreen`
3. 사용자가 `태그 상태 확인` 선택
4. `TagCheckScreen`
5. 앱이 태그 스캔 대기 상태 표시
6. 사용자가 NFC 태그를 기기에 가까이 댐
7. 앱이 태그 감지
8. 앱이 NDEF 지원 여부 확인
9. 앱이 쓰기 가능 여부 확인
10. 앱이 `maxSize` 확인
11. 앱이 `readOnly` 여부 확인
12. 앱이 NTAG213 144 byte 기준 저장 가능 여부 표시

### 결과 표시 기준

- NDEF 미지원이면 URL 저장 부적합으로 표시한다.
- `readOnly`이면 읽기는 가능하지만 쓰기는 불가로 표시한다.
- `maxSize`가 144 byte보다 작거나 현재 URL 예상 크기보다 작으면 용량 부족 가능성을 표시한다.
- 쓰기 가능하고 용량이 충분하면 URL 저장 적합으로 표시한다.

## 6. 쓰기 후 검증 흐름

### 정상 흐름

1. `NfcWriteScreen`에서 쓰기 성공
2. `WriteResultScreen`
3. 사용자가 `검증하기` 버튼 선택
4. `VerifyScreen`
5. 앱이 같은 NFC 태그 다시 스캔 요청
6. 사용자가 같은 태그를 기기에 가까이 댐
7. 앱이 `actualUrl` 읽기
8. 앱이 `expectedUrl`과 `actualUrl` 비교
9. 일치하면 검증 성공 표시
10. 사용자가 URL 열기 테스트 가능

### 불일치 흐름

1. `actualUrl`이 `expectedUrl`과 다름
2. `VerifyScreen`에서 불일치 경고 표시
3. 사용자가 다음 중 하나 선택
   - 다시 스캔
   - 다시 쓰기
   - URL 수정
   - 홈으로 이동

## 7. 오류 흐름

| 오류 상황 | 발생 위치 | 사용자에게 보여줄 메시지 방향 | 사용자가 선택할 수 있는 다음 행동 |
| --- | --- | --- | --- |
| NFC 미지원 | `HomeScreen`, `NfcReadScreen`, `NfcWriteScreen`, `VerifyScreen`, `TagCheckScreen` 진입 또는 NFC 세션 시작 전 | 이 기기는 NFC 기능을 지원하지 않는다고 안내 | 홈으로 이동, NFC 지원 기기 사용 안내 확인 |
| NFC 꺼짐 | NFC 세션 시작 전 또는 태그 스캔 대기 중 | NFC가 꺼져 있어 태그를 사용할 수 없다고 안내 | 설정에서 NFC 켜기, 다시 시도, 홈으로 이동 |
| 태그 미감지 | `NfcReadScreen`, `NfcWriteScreen`, `VerifyScreen`, `TagCheckScreen` 스캔 대기 중 | 태그를 찾지 못했으니 기기 가까이에 다시 대라고 안내 | 다시 스캔, 취소, 홈으로 이동 |
| NDEF 미지원 태그 | 태그 감지 후 NDEF 확인 단계 | 이 태그는 URL 저장 형식을 지원하지 않는다고 안내 | 다른 태그 사용, 다시 스캔, 홈으로 이동 |
| 읽기 전용 태그 | `NfcWriteScreen`, `TagCheckScreen`에서 쓰기 가능 여부 확인 단계 | 이 태그는 읽기 전용이라 수정할 수 없다고 안내 | 다른 태그 사용, 태그 읽기, 홈으로 이동 |
| 용량 부족 | `UrlPreviewScreen`, `NfcWriteScreen`, `TagCheckScreen` | URL이 태그 용량보다 커서 저장할 수 없다고 안내 | URL 수정, tracking parameter 제거, 다른 태그 사용 |
| 쓰기 실패 | `NfcWriteScreen`에서 NDEF URL Record 쓰기 중 | URL 저장에 실패했다고 안내 | 다시 시도, 태그 교체, URL 수정, 홈으로 이동 |
| 읽기 실패 | `NfcReadScreen`, `VerifyScreen`에서 URL 읽기 중 | 태그 내용을 읽지 못했다고 안내 | 다시 스캔, 취소, 홈으로 이동 |
| 세션 취소 | 사용자가 NFC 세션을 취소하거나 시스템이 세션을 종료 | NFC 작업이 취소되었다고 안내 | 다시 시작, 이전 화면으로 이동, 홈으로 이동 |
| 알 수 없는 오류 | 모든 NFC 작업 또는 URL 처리 중 예외 발생 | 알 수 없는 문제가 발생했다고 안내 | 다시 시도, 홈으로 이동, 문제 지속 시 기록 확인 안내 |

## 8. 화면 전환 요약

| Current Screen | User Action | Next Screen | Notes |
| --- | --- | --- | --- |
| `HomeScreen` | NFC 태그 만들기 선택 | `LinkTypeSelectScreen` | 새 URL을 NFC 태그에 쓰는 흐름 시작 |
| `HomeScreen` | NFC 태그 읽기 선택 | `NfcReadScreen` | 기존 태그의 NDEF URL Record 읽기 |
| `HomeScreen` | 태그 상태 확인 선택 | `TagCheckScreen` | 태그 쓰기 가능성과 용량 확인 |
| `LinkTypeSelectScreen` | Instagram 선택 | `InstagramInputScreen` | 계정명 기반 URL 자동 생성 흐름 |
| `LinkTypeSelectScreen` | LinkedIn/GitHub/Linktree/Portfolio/직접 입력 선택 | `CustomUrlInputScreen` | 전체 URL 입력 및 정규화 흐름 |
| `InstagramInputScreen` | 유효한 계정명 입력 후 다음 선택 | `UrlPreviewScreen` | `https://instagram.com/{username}` 생성 후 이동 |
| `InstagramInputScreen` | 비어 있거나 유효하지 않은 계정명 제출 | `InstagramInputScreen` | 입력 오류 메시지 표시 |
| `CustomUrlInputScreen` | 유효한 URL 입력 후 다음 선택 | `UrlPreviewScreen` | 스킴 보정, 형식 검사, optional tracking parameter 제거 후 이동 |
| `CustomUrlInputScreen` | 유효하지 않은 URL 제출 | `CustomUrlInputScreen` | URL 오류 메시지 표시 |
| `UrlPreviewScreen` | URL 수정 선택 | `InstagramInputScreen` 또는 `CustomUrlInputScreen` | 링크 유형에 따라 원래 입력 화면으로 복귀 |
| `UrlPreviewScreen` | URL 열기 선택 | 외부 브라우저 또는 인앱 브라우저 | 구현 방식은 feature spec에서 확정 |
| `UrlPreviewScreen` | NFC 태그에 쓰기 선택 | `NfcWriteScreen` | 저장 가능 용량을 통과한 경우에만 이동 |
| `UrlPreviewScreen` | 용량 초과 상태에서 쓰기 선택 | `UrlPreviewScreen` | 쓰기 이동 차단, URL 축소 안내 |
| `NfcWriteScreen` | 쓰기 성공 | `WriteResultScreen` | 성공 결과와 검증 CTA 표시 |
| `NfcWriteScreen` | 쓰기 실패 | `WriteResultScreen` | 실패 결과와 재시도 CTA 표시 |
| `WriteResultScreen` | 검증하기 선택 | `VerifyScreen` | 같은 태그 재스캔 요청 |
| `WriteResultScreen` | 다시 쓰기 선택 | `NfcWriteScreen` | 동일 URL로 쓰기 재시도 |
| `WriteResultScreen` | 홈으로 이동 선택 | `HomeScreen` | 작업 종료 |
| `VerifyScreen` | 검증 성공 후 URL 열기 선택 | 외부 브라우저 또는 인앱 브라우저 | 저장 URL 테스트 |
| `VerifyScreen` | 불일치 후 다시 쓰기 선택 | `NfcWriteScreen` | expectedUrl 기준으로 재쓰기 |
| `VerifyScreen` | 불일치 후 URL 수정 선택 | `InstagramInputScreen` 또는 `CustomUrlInputScreen` | 링크 유형에 따라 원래 입력 화면으로 복귀 |
| `NfcReadScreen` | URL 열기 선택 | 외부 브라우저 또는 인앱 브라우저 | 읽은 URL 테스트 |
| `NfcReadScreen` | URL 복사 선택 | `NfcReadScreen` | 클립보드 복사 후 같은 화면 유지 |
| `NfcReadScreen` | 다시 쓰기 선택 | `UrlPreviewScreen` 또는 `CustomUrlInputScreen` | 읽은 URL을 기반으로 쓰기 흐름 진입 |
| `TagCheckScreen` | 다시 스캔 선택 | `TagCheckScreen` | 다른 태그 또는 같은 태그 재확인 |
| `TagCheckScreen` | 홈으로 이동 선택 | `HomeScreen` | 상태 확인 종료 |
