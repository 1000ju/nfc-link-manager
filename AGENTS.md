# AGENTS.md

This file defines the working rules Codex must follow in this repository.

## Required Reading Before Implementation

- Before implementing features, read the project documents under `docs/`.
- Prioritize these documents:
  - `docs/planning.md`
  - `docs/user-flow.md`
  - `docs/feature-spec.md`
  - `docs/design-system.md`
  - `docs/mockup-guide.md`
- Treat the documents as the source of product, UX, architecture, and design intent.
- If a document conflicts with the user’s latest instruction, follow the user’s latest instruction and update the relevant document when appropriate.

## Repository Asset Locations

- `docs/mockups/` stores reference mockup images for planning and UI direction.
- `assets/images/` stores image assets intended to be bundled and used by the Flutter app.
- Do not move reference mockups into app assets unless the user explicitly asks for those images to ship in the app.

## Architecture Rules

- Keep UI, state management, and NFC platform logic separated.
- Widgets should not call Android/iOS NFC APIs directly.
- Define NFC-facing abstractions before wiring platform-specific implementations.
- Separate Android and iOS NFC logic because NFC capability, permissions, entitlement requirements, and runtime behavior differ by platform.
- Prefer small, focused modules over large mixed-purpose files.

## Dependency Rules

- Do not add large dependencies without proposing the tradeoff and receiving approval first.
- Before adding an NFC, state-management, routing, database, or code-generation package, explain why it is needed and what alternatives were considered.

## Security Rules

- Do not commit sensitive information.
- Do not commit API keys, signing keys, keystores, provisioning profiles, certificates, `.env` files, or authentication files.
- Keep generated local configuration files out of version control unless they are explicitly safe and required for reproducible setup.

## Validation Rules

- After a Flutter project exists and Dart/Flutter code changes are made, run `flutter analyze` before handoff.
- For the current documentation-only setup phase, do not run Flutter commands because Flutter project initialization and implementation are out of scope.
