# NFC Link Writer 디자인 시스템

이 문서는 NFC Link Writer 앱의 Flutter UI 구현 기준을 정의한다. `docs/mockups/`의 목업 톤을 참고하되, 픽셀 단위 복제가 아니라 전체 분위기, 정보 구조, 컴포넌트 일관성을 기준으로 구현한다.

## 1. Overall Design Direction

- 밝은 배경 위에 흰색 카드형 UI를 배치한다.
- 둥근 모서리와 부드러운 그림자로 iOS 스타일에 가까운 깔끔한 모바일 UI를 만든다.
- 메인 컬러는 딥 네이비 또는 블랙 계열을 사용해 CTA와 주요 텍스트의 신뢰감을 유지한다.
- 모든 주요 문구는 한국어 UI를 기본으로 한다.
- 화면 구조는 `큰 제목 → 짧은 설명 → 핵심 카드/입력 → 명확한 CTA 버튼` 순서를 따른다.
- 사용자에게 NFC 작업 상태를 즉시 이해시키기 위해 아이콘, 상태 배지, 진행 바, 스캔 비주얼을 적극 사용한다.
- 긴 설명보다 짧고 명확한 안내 문구를 우선한다.

## 2. Color System

| 역할 | Hex 예시 | 사용 기준 |
| --- | --- | --- |
| Primary color | `#071B4D` | 메인 CTA, 핵심 제목, 선택 상태 |
| Primary pressed | `#041236` | 버튼 pressed/active 상태 |
| Background color | `#F7F8FA` | 전체 앱 배경 |
| Background subtle | `#F2F4F7` | 카드 외부 보조 배경, 스캔 원형 배경 |
| Card background | `#FFFFFF` | 액션 카드, 정보 카드, 입력 카드 |
| Text primary | `#0B1020` | 제목, 주요 본문 |
| Text secondary | `#667085` | 설명, 보조 정보 |
| Text tertiary | `#98A2B3` | placeholder, 비활성 보조 텍스트 |
| Border color | `#E4E7EC` | 카드/입력 필드 테두리 |
| Border strong | `#D0D5DD` | 구분이 필요한 테두리 |
| Success color | `#12B76A` | 성공 상태, 저장 가능, 검증 성공 |
| Success background | `#ECFDF3` | 성공 배지/결과 카드 배경 |
| Error color | `#F04438` | 오류, 저장 불가, 검증 실패 |
| Error background | `#FEF3F2` | 오류 배지/결과 카드 배경 |
| Link color | `#2563EB` | URL 텍스트, 외부 링크 액션 |
| Warning color | `#F79009` | 용량 경고, 주의 상태 |
| Warning background | `#FFFAEB` | 경고 카드/배지 배경 |

구현 시 색상값은 `ThemeData.colorScheme`, 별도 `AppColors`, 또는 design token 클래스로 관리하고 화면에서 직접 Hex를 반복하지 않는다.

## 3. Typography

기본 폰트는 시스템 폰트를 사용한다. Flutter에서는 별도 폰트를 추가하지 않는 한 `TextTheme` 기반으로 관리한다.

| 항목 | Size | Weight | Line height | 사용 기준 |
| --- | --- | --- | --- | --- |
| Screen title | 24 | 700 | 1.25 | 화면 최상단 큰 제목 |
| Section title | 18 | 700 | 1.35 | 카드 그룹 제목, 결과 제목 |
| Body text | 15 | 400 | 1.5 | 일반 설명 문구 |
| Body strong | 15 | 600 | 1.5 | 카드 내 주요 라벨 |
| Caption text | 12 | 400 | 1.4 | 보조 설명, 상태 설명 |
| Button text | 15 | 700 | 1.2 | CTA 버튼 텍스트 |
| URL text | 13 | 600 | 1.4 | URL 표시, 링크 텍스트 |
| Status text | 12 | 700 | 1.2 | 상태 배지 텍스트 |

긴 URL은 줄바꿈을 허용하되, 카드 너비를 넘지 않도록 `softWrap`, `maxLines`, overflow 정책을 화면별로 명확히 정한다.

## 4. Layout and Spacing

- 전체 화면 horizontal padding: 24px
- 상단 여백: status bar 이후 28~40px
- 화면 제목과 설명 간격: 8px
- 설명과 첫 콘텐츠 간격: 28~32px
- 카드 간 간격: 12px
- 섹션 간 간격: 24~32px
- 카드 내부 padding: 16~20px
- 입력 필드와 보조 미리보기 카드 간격: 12~16px
- CTA 버튼 높이: 52~56px
- 하단 고정 버튼 사용 화면: `InstagramInputScreen`, `CustomUrlInputScreen`, `UrlPreviewScreen`
- NFC 스캔 화면은 콘텐츠를 세로 중앙에 가깝게 배치하고, 취소 버튼은 하단에 둔다.
- 결과 화면은 성공/실패 비주얼을 상단 중앙에 두고, URL 카드와 CTA를 아래에 배치한다.
- Safe area를 고려해 하단 버튼은 최소 20px 이상의 bottom padding을 둔다.

입력 화면의 콘텐츠는 상단 제목 영역, 중앙 입력/미리보기 영역, 하단 CTA 영역으로 분리한다.

## 5. Component Style

### Primary button

- 목적: 다음 단계 이동, NFC 쓰기, 검증 등 가장 중요한 행동을 수행한다.
- UI 특징: 딥 네이비 배경, 흰색 텍스트, 14~16px radius, 52~56px 높이, 전체 너비.
- 사용 화면: `InstagramInputScreen`, `CustomUrlInputScreen`, `UrlPreviewScreen`, `WriteResultScreen`
- 구현 시 주의점: disabled 상태는 배경을 `#D0D5DD`, 텍스트를 `#FFFFFF` 또는 `#98A2B3`로 처리하고 눌림 효과를 과하게 주지 않는다.

### Secondary button

- 목적: 취소, 홈으로 이동, 보조 액션을 제공한다.
- UI 특징: 흰색 또는 투명 배경, 연한 회색 border, 딥 네이비 텍스트, Primary button과 동일한 높이.
- 사용 화면: `NfcWriteScreen`, `WriteResultScreen`, `VerifyScreen`, `TagCheckScreen`
- 구현 시 주의점: Primary button보다 시각적 우선순위가 낮아야 한다.

### Action card

- 목적: Home 또는 LinkType 선택에서 주요 이동 액션을 표현한다.
- UI 특징: 흰색 카드, 아이콘 박스, 제목, 짧은 설명, 우측 chevron, 16px radius, 약한 그림자.
- 사용 화면: `HomeScreen`, `LinkTypeSelectScreen`
- 구현 시 주의점: 카드 전체가 tap target이며 최소 높이 72px 이상을 권장한다.

### Info card

- 목적: URL, 태그 정보, 결과 세부 정보 등 읽기용 정보를 묶어 보여준다.
- UI 특징: 흰색 카드, 16px radius, 16~20px padding, 라벨과 값의 명확한 계층.
- 사용 화면: `UrlPreviewScreen`, `NfcReadScreen`, `TagCheckScreen`, `WriteResultScreen`
- 구현 시 주의점: URL은 Link color를 사용하고 너무 긴 값은 줄바꿈한다.

### Text input field

- 목적: Instagram 계정명 또는 URL을 입력받는다.
- UI 특징: 흰색 또는 매우 밝은 배경, 12~14px radius, 연한 회색 border, focus 시 Primary border.
- 사용 화면: `InstagramInputScreen`, `CustomUrlInputScreen`
- 구현 시 주의점: label, placeholder, helper/error text를 분리하고 error 상태는 border와 message를 함께 표시한다.

### Toggle row

- 목적: tracking parameter 제거 옵션 같은 boolean 선택을 제공한다.
- UI 특징: 흰색 카드형 row, 제목/설명, 우측 switch, 14~16px radius.
- 사용 화면: `CustomUrlInputScreen`
- 구현 시 주의점: switch 값 변경 시 정규화 URL 미리보기가 즉시 갱신되어야 한다.

### Status badge

- 목적: 저장 가능, 지원함, 쓰기 가능, 오류 등 짧은 상태를 표시한다.
- UI 특징: 작은 pill 형태, 상태별 배경색과 텍스트색 사용, 아이콘 선택 가능.
- 사용 화면: `UrlPreviewScreen`, `NfcReadScreen`, `TagCheckScreen`, `VerifyScreen`
- 구현 시 주의점: 색상만으로 의미를 전달하지 말고 텍스트도 함께 제공한다.

### Progress bar

- 목적: NTAG213 144 byte 중 URL 사용량을 보여준다.
- UI 특징: 얇은 라운드 bar, 사용량은 Primary 또는 Success 색상, 초과/경고는 Warning 또는 Error 색상.
- 사용 화면: `UrlPreviewScreen`, `TagCheckScreen`, `NfcReadScreen`
- 구현 시 주의점: 숫자 표기와 함께 제공한다. 예: `62 / 144 byte (43%)`

### NFC scanning visual

- 목적: 사용자가 NFC 태그 스캔 대기 상태임을 즉시 이해하게 한다.
- UI 특징: 중앙 원형 그래픽, 파동 또는 회전 링, NFC/휴대폰 아이콘, 밝은 블루 계열 보조색.
- 사용 화면: `NfcWriteScreen`, `VerifyScreen`, `NfcReadScreen`, `TagCheckScreen`
- 구현 시 주의점: 애니메이션은 과하지 않게 유지하고, 접근성을 위해 텍스트 안내를 반드시 함께 제공한다.

### Success result visual

- 목적: 쓰기 성공, 검증 성공, 저장 가능 상태를 명확히 표시한다.
- UI 특징: 초록색 체크 아이콘, 원형 배경, 짧은 성공 제목, 보조 설명.
- 사용 화면: `WriteResultScreen`, `VerifyScreen`, `TagCheckScreen`
- 구현 시 주의점: 성공 후 다음 행동인 검증하기, URL 열기, 홈으로 이동 CTA를 명확히 제공한다.

## 6. Screen-Level Design Notes

### HomeScreen

- 앱 이름과 메인 문구를 크게 배치한다.
- 상단 일러스트 또는 NFC/휴대폰 그래픽은 보조 요소로 사용한다.
- 세 개의 액션 카드는 동일한 높이와 구조를 유지한다.

### LinkTypeSelectScreen

- 뒤로가기 아이콘을 상단에 둔다.
- 각 링크 유형은 브랜드 아이콘 또는 구분 아이콘, 제목, 짧은 설명, chevron으로 구성한다.
- 선택지는 카드 리스트로 정렬하고 스캔 가능한 밀도를 유지한다.

### InstagramInputScreen

- Instagram 아이콘을 중앙 상단 카드나 원형 배경에 배치한다.
- 계정명 입력 필드 아래에 생성 URL 미리보기를 별도 카드로 보여준다.
- 하단 Primary button은 입력값이 유효할 때만 활성화한다.

### CustomUrlInputScreen

- URL 입력 필드와 정규화 URL 미리보기를 분리한다.
- tracking parameter 제거 옵션은 toggle row로 제공한다.
- 유효성 상태는 아이콘과 짧은 문구로 즉시 표시한다.

### UrlPreviewScreen

- 최종 URL 확인 카드가 화면의 핵심이다.
- 링크 유형, 최종 URL, 예상 크기, 사용량, 저장 가능 여부를 같은 카드 안에서 정리한다.
- URL 열기/수정하기는 보조 버튼, NFC 태그에 쓰기는 Primary button으로 둔다.

### NfcWriteScreen

- 중앙에 NFC scanning visual을 크게 배치한다.
- 저장할 URL 카드는 하단 쪽에 고정적으로 보여준다.
- 취소 버튼은 Secondary button으로 제공한다.

### WriteResultScreen

- 성공 시 초록색 체크 비주얼을 상단 중앙에 둔다.
- 저장된 URL 카드를 보여준 뒤 검증하기를 Primary CTA로 둔다.
- 실패 시 실패 원인과 다시 시도 버튼을 명확히 보여준다.

### VerifyScreen

- 검증 중에는 scanning visual을 사용한다.
- 결과 상태는 성공/불일치가 즉시 구분되도록 색상과 텍스트를 함께 사용한다.
- 불일치 시 expectedUrl과 actualUrl을 모두 표시한다.

### NfcReadScreen

- 읽은 URL을 가장 먼저 보여준다.
- 태그 타입, 쓰기 가능 여부, 최대 용량, 현재 사용량은 정보 카드로 묶는다.
- URL 열기, 복사, 다시 쓰기 액션은 하단에 같은 우선순위의 보조 액션으로 배치한다.

### TagCheckScreen

- NDEF 지원, 쓰기 가능, maxSize, readOnly, 저장 가능 여부를 리스트 형태로 정리한다.
- 최종 판단은 성공/경고/오류 상태 카드로 분리한다.
- 다시 스캔과 홈으로 이동을 명확히 제공한다.

## 7. Implementation Notes for Flutter

### ThemeData로 관리할 항목

- `ColorScheme`: primary, background, surface, error
- `TextTheme`: screen title, section title, body, caption, button, URL text
- `ElevatedButtonThemeData`: Primary button
- `OutlinedButtonThemeData`: Secondary button
- `InputDecorationTheme`: 입력 필드 radius, border, focus/error 상태
- `CardTheme`: 카드 배경, radius, elevation, margin
- `IconThemeData`: 기본 아이콘 색상과 크기

### 공통 버튼 위젯으로 분리할 항목

- `PrimaryButton`: 주요 CTA
- `SecondaryButton`: 취소/홈/보조 액션
- `IconActionButton`: URL 열기, 복사, 수정 같은 아이콘 포함 액션
- 공통 속성: loading, disabled, fullWidth, icon, onPressed

### 공통 카드 위젯으로 분리할 항목

- `ActionCard`: Home/LinkType 선택 카드
- `InfoCard`: URL/태그 정보 카드
- `StatusCard`: 성공/경고/오류 결과 카드
- `UrlCard`: 긴 URL 표시와 복사/열기 액션에 특화된 카드

### 공통 입력 필드 위젯으로 분리할 항목

- `AppTextField`: 일반 텍스트 입력
- `UrlTextField`: URL 입력 전용 키보드, validation message, clear button 포함
- `UsernameTextField`: Instagram 계정명 입력 전용
- `TrackingCleanupToggle`: tracking parameter 제거 옵션 row

### 하드코딩을 피해야 할 디자인 값

- 색상 Hex 값
- radius 값
- 화면 padding
- 카드 padding
- 버튼 높이
- 텍스트 스타일
- shadow/elevation
- 상태별 badge 색상
- progress bar 색상과 높이

디자인 값은 `AppColors`, `AppSpacing`, `AppRadius`, `AppTextStyles` 같은 token 파일 또는 `ThemeExtension`으로 관리한다. 화면 구현에서는 token을 참조하고 임의 숫자를 반복하지 않는다.
