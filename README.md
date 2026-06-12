# NFC Link Manager

NFC Link Manager is a Flutter app for managing profile links and writing selected links to NFC tags.

Users should be able to manage links such as Instagram, LinkedIn, GitHub, personal websites, portfolios, contact pages, or other profile URLs, then write one selected destination to an NFC tag for easy sharing.

## Purpose

- Provide a simple mobile-first way to manage personal profile links.
- Support NFC tag writing for offline-to-online profile sharing.
- Keep the app structure ready for Android and iOS while respecting platform-specific NFC differences.

## Planned Features

- Link management for profile URLs.
- URL validation before saving or writing.
- Profile preview before writing to an NFC tag.
- NFC tag writing flow.
- NFC tag reading flow.
- Platform-specific NFC capability and permission handling.
- Local persistence for saved links.
- Clear error states for unsupported devices, invalid URLs, permission issues, and NFC write/read failures.

## Documentation Structure

- `AGENTS.md`: Rules Codex must follow while working in this repository.
- `docs/planning.md`: Product planning template and MVP scope.
- `docs/user-flow.md`: User journey and screen flow template.
- `docs/feature-spec.md`: Feature-level specification template.
- `docs/design-system.md`: UI design system template.
- `docs/mockup-guide.md`: Mockup image naming and interpretation guide.
- `docs/mockups/`: Reference mockup images for UI direction.
- `assets/images/`: Image assets intended for the Flutter app.

## Suggested Development Order

1. Complete the planning, user flow, feature spec, design system, and mockup guide.
2. Add reference mockups under `docs/mockups/`.
3. Initialize the Flutter project only after the product and UI direction are clear.
4. Implement the base app shell, routing, and screen structure.
5. Add link management and local persistence.
6. Add profile preview and URL validation.
7. Add NFC write/read abstractions.
8. Implement Android and iOS NFC platform logic separately.
9. Add validation, error handling, and device-level testing.
