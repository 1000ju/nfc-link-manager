# NFC Link Manager 목업 가이드

이 문서는 `docs/mockups/`에 있는 10개 목업 이미지를 Flutter UI 구현 시 어떻게 해석하고 반영할지 정의한다. 목업은 제품 방향과 정보 구조를 보여주는 참고 자료이며, 실제 구현 기준은 `docs/feature-spec.md`와 `docs/design-system.md`를 함께 따른다.

## 1. Mockup File Inventory

| File Name | Target Screen | Purpose | Implementation Priority |
| --- | --- | --- | --- |
| `01_home.png` | `HomeScreen` | 앱 진입 화면과 세 가지 주요 액션 구조를 정의한다. | 1차 구현 |
| `02_link_type_select.png` | `LinkTypeSelectScreen` | 링크 유형 선택 리스트와 카드 구조를 정의한다. | 1차 구현 |
| `03_instagram_input.png` | `InstagramInputScreen` | Instagram 계정명 입력과 자동 생성 URL 미리보기를 정의한다. | 1차 구현 |
| `04_custom_url_input.png` | `CustomUrlInputScreen` | 전체 URL 입력, 정규화 미리보기, tracking parameter 제거 옵션을 정의한다. | 1차 구현 |
| `05_url_preview.png` | `UrlPreviewScreen` | 최종 URL, 예상 byte, 저장 가능 여부, 쓰기 CTA 구조를 정의한다. | 1차 구현 |
| `06_nfc_write.png` | `NfcWriteScreen` | NFC 태그 쓰기 대기 상태와 저장할 URL 표시 방식을 정의한다. | 다음 구현 |
| `07_write_result.png` | `WriteResultScreen` | 쓰기 성공/실패 결과와 검증 CTA 구조를 정의한다. | 다음 구현 |
| `08_verify.png` | `VerifyScreen` | 쓰기 후 검증 중인 상태와 NFC 재스캔 안내를 정의한다. | 다음 구현 |
| `09_nfc_read.png` | `NfcReadScreen` | 읽은 URL, 태그 정보, 후속 액션 구성을 정의한다. | 다음 구현 |
| `10_tag_check.png` | `TagCheckScreen` | 태그 상태 검사 결과와 저장 가능 여부 판단 UI를 정의한다. | 다음 구현 |

## 2. Global Mockup Interpretation Rules

- 목업은 픽셀 단위 완전 동일 구현이 아니라 UI 방향성 참고용이다.
- 화면 구조, 정보 우선순위, CTA 위치는 최대한 유지한다.
- 색상, 폰트, 간격, radius, shadow는 `docs/design-system.md` 기준으로 정리한다.
- 화면별 기능, 입력값, 예외 상태는 `docs/feature-spec.md` 기준을 따른다.
- 한국어 UI를 유지한다.
- 밝은 배경을 사용한다.
- 흰색 카드형 UI를 기본 단위로 사용한다.
- 둥근 모서리와 부드러운 그림자를 사용한다.
- 딥 네이비 또는 블랙 계열을 메인 컬러로 사용한다.
- 큰 제목, 짧은 설명, 명확한 CTA 버튼 구조를 유지한다.
- iOS 스타일에 가까운 깔끔한 모바일 UI를 지향한다.
- 기기 크기, safe area, 접근성, 긴 URL 표시 문제 때문에 세부 간격과 줄바꿈은 구현 단계에서 조정할 수 있다.

## 3. Screen-by-Screen Mockup Notes

### `01_home.png`

- 대상 화면: `HomeScreen`
- 화면 목적: 앱 진입 후 NFC 태그 만들기, NFC 태그 읽기, 태그 상태 확인으로 이동하게 한다.
- 주요 UI 요소:
  - 앱 이름 `NFC Link Manager`
  - 메인 문구와 짧은 설명
  - NFC/휴대폰 일러스트
  - 세 개의 액션 카드
- 주요 CTA: `NFC 태그 만들기`
- 정보 우선순위: 앱 목적 → 주요 설명 → 태그 만들기 → 태그 읽기 → 태그 상태 확인
- 구현 시 유지할 요소:
  - 큰 제목과 짧은 설명
  - 흰색 액션 카드 3개
  - 카드 우측 chevron
  - 딥 네이비 계열 첫 번째 액션 아이콘
- 구현 시 유연하게 조정 가능한 요소:
  - 상단 일러스트 크기와 위치
  - 카드 내부 아이콘 종류
  - 화면 높이에 따른 카드 간격
- 관련 문서:
  - `docs/feature-spec.md`의 `HomeScreen` 섹션
  - `docs/design-system.md`

### `02_link_type_select.png`

- 대상 화면: `LinkTypeSelectScreen`
- 화면 목적: 저장할 링크 유형을 선택하게 한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 화면 제목과 설명
  - Instagram, LinkedIn, GitHub, Linktree, Portfolio, 직접 입력 카드
- 주요 CTA: 링크 유형 카드 선택
- 정보 우선순위: 제목 → 설명 → 링크 유형 목록
- 구현 시 유지할 요소:
  - 링크 유형별 카드 리스트
  - 아이콘, 제목, 짧은 설명, chevron 구조
  - Instagram 선택 시 별도 입력 흐름으로 분기
- 구현 시 유연하게 조정 가능한 요소:
  - 브랜드 아이콘 사용 여부
  - 카드 높이
  - 설명 문구 길이
- 관련 문서:
  - `docs/feature-spec.md`의 `LinkTypeSelectScreen` 섹션
  - `docs/design-system.md`

### `03_instagram_input.png`

- 대상 화면: `InstagramInputScreen`
- 화면 목적: Instagram 계정명만 입력받아 URL을 자동 생성한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 화면 제목과 설명
  - Instagram 아이콘 비주얼
  - 계정명 입력 필드
  - 생성 URL 미리보기 카드
  - 하단 Primary CTA
- 주요 CTA: `다음`
- 정보 우선순위: 제목 → Instagram 입력 목적 → 계정명 입력 → 생성 URL 미리보기 → 다음
- 구현 시 유지할 요소:
  - 계정명 입력 중심 구조
  - `@` 제거 후 URL 미리보기
  - 하단 고정 CTA
- 구현 시 유연하게 조정 가능한 요소:
  - Instagram 아이콘 크기
  - 미리보기 카드 위치
  - 키보드 노출 시 스크롤 처리
- 관련 문서:
  - `docs/feature-spec.md`의 `InstagramInputScreen` 섹션
  - `docs/design-system.md`

### `04_custom_url_input.png`

- 대상 화면: `CustomUrlInputScreen`
- 화면 목적: LinkedIn, GitHub, Linktree, Portfolio, 직접 URL 입력과 정규화를 처리한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 화면 제목과 설명
  - URL 입력 필드
  - 정규화 URL 미리보기 카드
  - tracking parameter 제거 toggle row
  - 하단 Primary CTA
- 주요 CTA: `다음`
- 정보 우선순위: 제목 → URL 입력 → 정규화 결과 → 옵션 → 다음
- 구현 시 유지할 요소:
  - URL 입력과 미리보기 분리
  - 유효성 상태 표시
  - tracking parameter 제거 옵션
  - 하단 고정 CTA
- 구현 시 유연하게 조정 가능한 요소:
  - toggle row 문구 길이
  - 정규화 결과 카드 높이
  - helper text 위치
- 관련 문서:
  - `docs/feature-spec.md`의 `CustomUrlInputScreen` 섹션
  - `docs/design-system.md`

### `05_url_preview.png`

- 대상 화면: `UrlPreviewScreen`
- 화면 목적: NFC 태그에 저장할 최종 URL과 저장 가능 여부를 확인한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 화면 제목과 설명
  - 최종 URL 정보 카드
  - 링크 유형
  - 예상 크기
  - NTAG213 144 byte 사용량
  - 저장 가능 여부
  - URL 열기, 수정하기, NFC 태그에 쓰기 버튼
- 주요 CTA: `NFC 태그에 쓰기`
- 정보 우선순위: 최종 URL → 용량/저장 가능 여부 → 보조 액션 → 쓰기 CTA
- 구현 시 유지할 요소:
  - 정보 카드 중심 구조
  - byte 사용량 progress bar
  - 저장 가능 상태 배지
  - 쓰기 CTA의 가장 높은 시각적 우선순위
- 구현 시 유연하게 조정 가능한 요소:
  - URL 줄바꿈 방식
  - progress bar 두께
  - 보조 버튼 배치
- 관련 문서:
  - `docs/feature-spec.md`의 `UrlPreviewScreen` 섹션
  - `docs/design-system.md`

### `06_nfc_write.png`

- 대상 화면: `NfcWriteScreen`
- 화면 목적: 사용자가 NFC 태그에 휴대폰을 가까이 대도록 안내하고 URL 쓰기를 진행한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 화면 제목과 설명
  - NFC scanning visual
  - 저장할 URL 카드
  - 취소 버튼
- 주요 CTA: NFC 태그 스캔 행동
- 정보 우선순위: 스캔 안내 → 시각적 스캔 상태 → 저장할 URL → 취소
- 구현 시 유지할 요소:
  - 중앙 스캔 비주얼
  - `휴대폰 뒷면을 NFC 태그에 가까이 대세요`에 준하는 명확한 안내
  - 저장할 URL 표시
- 구현 시 유연하게 조정 가능한 요소:
  - 애니메이션 방식
  - 휴대폰/NFC 아이콘 그래픽
  - 취소 버튼 위치
- 관련 문서:
  - `docs/feature-spec.md`의 `NfcWriteScreen` 섹션
  - `docs/design-system.md`

### `07_write_result.png`

- 대상 화면: `WriteResultScreen`
- 화면 목적: NFC 쓰기 성공 또는 실패 결과를 표시하고 검증 흐름으로 연결한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 성공 체크 비주얼 또는 실패 비주얼
  - 결과 제목과 설명
  - 저장한 URL 카드
  - 검증하기 버튼
  - 홈으로 이동 버튼
- 주요 CTA: `검증하기`
- 정보 우선순위: 결과 상태 → 저장 URL → 검증하기 → 홈으로 이동
- 구현 시 유지할 요소:
  - 성공 시 초록색 체크 비주얼
  - 저장 URL 카드
  - 검증하기 Primary CTA
- 구현 시 유연하게 조정 가능한 요소:
  - confetti 같은 보조 장식
  - 실패 상태 비주얼
  - 홈으로 이동 버튼 스타일
- 관련 문서:
  - `docs/feature-spec.md`의 `WriteResultScreen` 섹션
  - `docs/design-system.md`

### `08_verify.png`

- 대상 화면: `VerifyScreen`
- 화면 목적: 쓰기 후 같은 태그를 다시 읽어 저장 URL 일치 여부를 검증한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 화면 제목과 설명
  - 원형 scanning/progress visual
  - 같은 태그를 대라는 안내 문구
- 주요 CTA: 같은 NFC 태그 다시 스캔
- 정보 우선순위: 검증 목적 → 스캔 상태 → 사용자 행동 안내
- 구현 시 유지할 요소:
  - 중앙 검증 진행 비주얼
  - 자동 읽기 진행 중임을 보여주는 문구
  - 검증 대상이 같은 태그라는 안내
- 구현 시 유연하게 조정 가능한 요소:
  - progress animation 방식
  - 검증 결과 표시 위치
  - 불일치 상태의 상세 레이아웃
- 관련 문서:
  - `docs/feature-spec.md`의 `VerifyScreen` 섹션
  - `docs/design-system.md`

### `09_nfc_read.png`

- 대상 화면: `NfcReadScreen`
- 화면 목적: 기존 NFC 태그에 저장된 URL과 태그 정보를 표시한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 화면 제목과 설명
  - 저장된 URL 카드
  - 태그 타입, 쓰기 가능 여부, 최대 용량, 현재 사용량 정보
  - URL 열기, URL 복사, 다시 쓰기 액션
- 주요 CTA: `URL 열기`
- 정보 우선순위: 저장된 URL → 태그 정보 → URL 열기/복사/다시 쓰기
- 구현 시 유지할 요소:
  - 읽은 URL을 가장 상단 정보로 표시
  - 태그 메타데이터 정보 카드
  - 세 개의 후속 액션
- 구현 시 유연하게 조정 가능한 요소:
  - 후속 액션 버튼 배치
  - 태그 정보 라벨 문구
  - URL 카드 높이
- 관련 문서:
  - `docs/feature-spec.md`의 `NfcReadScreen` 섹션
  - `docs/design-system.md`

### `10_tag_check.png`

- 대상 화면: `TagCheckScreen`
- 화면 목적: 태그가 URL 저장에 적합한지 판단한다.
- 주요 UI 요소:
  - 뒤로가기 버튼
  - 화면 제목과 설명
  - NDEF 지원 여부
  - 쓰기 가능 여부
  - 최대 용량
  - 현재 사용량
  - 읽기 전용 여부
  - 최종 저장 가능 여부 카드
- 주요 CTA: 태그 상태 확인 결과에 따른 다음 행동
- 정보 우선순위: 태그 지원/쓰기 가능 여부 → 용량 정보 → 최종 저장 가능 여부
- 구현 시 유지할 요소:
  - 상태 리스트 구조
  - 성공/실패 상태 배지
  - 최종 판단 카드
- 구현 시 유연하게 조정 가능한 요소:
  - 리스트 row 높이
  - 상태 문구
  - 다시 스캔/홈 이동 버튼 추가 위치
- 관련 문서:
  - `docs/feature-spec.md`의 `TagCheckScreen` 섹션
  - `docs/design-system.md`

## 4. Asset Usage Policy

- `docs/mockups/`는 개발 참고용 목업 이미지 저장 위치다.
- `assets/images/`는 실제 Flutter 앱에서 사용하는 이미지 리소스 저장 위치다.
- `docs/mockups/` 이미지는 앱 번들에 포함하지 않는다.
- 실제 앱에서 사용할 아이콘이나 이미지는 `assets/images/`로 이동한 뒤 `pubspec.yaml`에 등록한다.
- 목업 이미지를 그대로 앱 화면 배경으로 사용하지 않는다.
- 목업의 아이콘, 일러스트, 장식 요소는 동일 파일 재사용이 아니라 구현 가능한 Flutter 위젯, 아이콘, 앱용 asset으로 재구성한다.
- 앱에 포함할 이미지가 생기면 파일명, 사용 화면, 라이선스 또는 출처를 별도로 확인한다.

## 5. Implementation Priority

### 1차 구현에서 우선 반영

- `HomeScreen`
- `LinkTypeSelectScreen`
- `InstagramInputScreen`
- `CustomUrlInputScreen`
- `UrlPreviewScreen`

1차 구현은 실제 NFC 기능 없이 링크 유형 선택, 입력, URL 정규화, 용량 계산, 미리보기까지의 UI 완성도를 우선한다.

### 다음 구현에서 반영

- `NfcWriteScreen`
- `WriteResultScreen`
- `VerifyScreen`
- `NfcReadScreen`
- `TagCheckScreen`

다음 구현은 `nfc_manager` 기반 NFC 읽기/쓰기/검증 흐름과 Android/iOS 실기기 테스트 단계에서 목업을 반영한다.
