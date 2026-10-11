# AGENTS.md

## Project
cosmox Flutter client. Dart + Rust two-layer architecture: UI lives in `lib/`; the Rust side wraps the upstream `cosmox-sdk` (git dev branch) and exposes it to Dart via flutter_rust_bridge 2.12.

## Key Paths
- Rust API definitions: `rust/src/api/cosmox.rs` (regenerate bindings after changes)
- FRB config: `flutter_rust_bridge.yaml` (rust_root: rust/, dart_output: lib/src/rust)
- Global singletons: `SdkProxy` (`lib/core/sdk_proxy.dart` — all SDK calls go through it, never use `CosmoxSdk` directly); `AuthController` (`lib/core/state.dart`)
- `rust_builder/` is cargokit glue — do not modify; already excluded in `analysis_options.yaml`

## Environment / Toolchain Notes
- Flutter via fvm (`.fvmrc`: stable) or nix flake (`flake.nix` provides an FHS devShell with Android SDK 36, jdk17, mpv, gstreamer, `flutter_rust_bridge_codegen`)
- Rust edition 2024; cargokit builds the Rust lib as part of Flutter via `rust_builder`. After changing Rust deps, rebuild inside `rust/`
- Desktop media uses `media_kit` (libmpv/gstreamer); missing system libs cause Linux link failures

## Commands
- Regenerate bindings (required after changing `rust/`): `flutter_rust_bridge_codegen generate`
- Dependencies: `flutter pub get`
- Static analysis: `flutter analyze`
- Format: `dart format .`
- All tests: `flutter test`; single file: `flutter test test/unit/validate_test.dart`
- Codegen (freezed/json): `dart run build_runner build`
- Localization: edit `lib/l10n/app_en.arb` / `app_zh.arb`, then `flutter gen-l10n` (`generate: true` also runs on build)
- Linux desktop build needs system deps (clang/cmake/ninja/pkg-config/libmpv-dev/libgtk-3-dev/gstreamer, see `.github/workflows/flutter_build.yml`)

## Architecture Conventions
- Four auth states (`AuthStatus`) drive the `go_router` redirect; cross-page args are usually passed via `state.extra` payloads (e.g. `VideoPlaybackPayload`)
- Theme, server address, and token persist in SharedPreferences; the token is a JWT whose uid is parsed from the `sub` claim

## Comment & Commit Message Style
- Comments and commit messages are English-first
- If the function name (or code) already conveys the meaning, do not add a comment
- Do not use dashed-divider comment banners (e.g. `// ---`, `// ===`)
- Comments and commit messages must not count or enumerate things (e.g. no "3 endpoints added", no "methods: a, b, c" listings)

## Code Naming Conventions
- Pages: `XxxPage` (StatefulWidget) + `_XxxPageState`; logger name matches the class name
- Widget components: `Component` suffix, e.g. `ContainerInfoComponent`, `PathSelectorComponent`
- Controllers: `XxxController extends ChangeNotifier`, private fields `_camelCase`, public getters
- State fields private `_camelCase` (`_libraries`, `_selectedIndex`, `_isLoading`)
- Methods/variables lowerCamelCase; top-level `const` also lowerCamelCase
- Enum members lowerCamelCase; route paths lowercase with `/`, e.g. `/library/view/:id`

## Logging Conventions
- One logger per class at the top: `final Logger _logger = Logger('<ClassName>');`
- Levels: `fine` for debug/data results; `info` for key flows (`[Login] Success`); `warning` for recoverable anomalies; `severe` for errors, with error as 2nd arg and optional stackTrace as 3rd
- English short-sentence messages; subsystem messages get a prefix like `[Login]`, `[Auth]`
- Never use `print`; output is centralized via `Logger.root.onRecord` in `main.dart`

## API Request Conventions
- All requests go through `SdkProxy.instance`; pages must not instantiate `CosmoxSdk` directly
- Proxy methods use named parameters: `libraryGet({required BigInt lid})`; always route through `_value`/`_void`/`_sync` (token renewal + session-expiry/disconnect routing)
- Error handling: `SdkError_Unauthenticated` / `ConnectionFailed` are converted to global events by SdkProxy; pages only handle the remaining errors
- Adding an endpoint: Rust method in `rust/src/api/cosmox.rs` → `flutter_rust_bridge_codegen generate` → `SdkProxy` forwarding → page call
- Page call pattern:
  ```dart
  try {
    final x = await SdkProxy.instance.xxx();
    _logger.fine('... loaded: ${x.length}');
    if (!mounted) return;
    setState(() => ...);
  } catch (error) {
    _logger.severe('Failed to ...', error);
    if (!mounted) return;
    scaffoldMessengerKey.currentState?.showSnackBar(...);
  }
  ```
- Check `mounted` before `setState`; surface user-facing errors via `scaffoldMessengerKey` SnackBar, not a captured context

## Generated Code (do not hand-edit)
- `lib/src/rust/**`, `rust/src/frb_generated.rs`, `lib/**/*.freezed.dart`, `lib/**/*.g.dart`, `lib/l10n/app_localizations*.dart` are generated — never hand-edit them or commit manual edits to their diff
- Changes only via regeneration:
  - FRB bindings: edit `rust/src/api/**`, then `flutter_rust_bridge_codegen generate`
  - freezed/json: `dart run build_runner build`
  - l10n: edit `lib/l10n/*.arb`, then `flutter gen-l10n`
- Pre-commit self-check: any diff under `lib/src/rust` / `rust/src/frb_generated.rs` must come from re-running the codegen, not hand edits

## Pre-commit Checklist (must run locally)
1. `dart format .` (CI has a format check, but it is continue-on-error — do not rely on it)
2. `flutter analyze` (same, no new warnings)
3. `flutter test` (CI does not block on it either)
When Rust code changed, also run: `cd rust && cargo clippy && cargo test` (if tests exist).

## Commit Message Format
Conventional Commits:
`<type>(<scope>): <subject>`
- type: `feat` / `fix` / `refactor` / `docs` / `style` / `test` / `build` / `ci` / `chore` (in practice: `feat` / `fix` / `refactor`)
- scope: optional, prefer module names like `sdk`, `player`, `dashboard`, `l10n`, `rust`; omit for repo-wide changes
- subject: English imperative, short, no trailing period, e.g. `feat: play videos from the resource detail page`
- body: bullet list starting with `-`, one change per bullet, explaining motivation and surface
- pure refactors must state behavior is unchanged: `No behavior change; ...`
- optional trailing `Refs:` line, e.g. `Refs: metadata editor route /dashboard/metadata/editor`
- When bindings were regenerated, note in the body that `flutter_rust_bridge_codegen generate` was run

## Commit Granularity
- One feature per commit, self-contained across all layers: Rust method + regenerated FRB bindings + `SdkProxy` forwarding + page + l10n keys + synced generated code — never split into half-finished commits
- Generated code from `flutter_rust_bridge_codegen generate` / `dart run build_runner build` / `flutter gen-l10n` must be committed together with the source change in the same commit
- Pure refactor commits that exist to satisfy clippy (e.g. `clippy::too_many_arguments`) should say so in the body

## Branch Strategy
- Active development branch: `dev`; PRs target `dev`; `master` is the release baseline
- Feature branches are cut from `dev` and deleted after merge
- CI triggers on both `master` and `dev`

## Auth Flow
Four auth states (`AuthController` is the only state owner; pages/guides call `stateNext()`, `storeToken*`, `storeAddress`, or `init`):
```
serverUnselected ──server address stored──> serverUninitialized
serverUninitialized ──first-boot setup done──> unauthenticated
unauthenticated ──login──> authenticated
authenticated ──logout / token expired──> unauthenticated
(any) ──server unreachable──> serverUnselected
```
`SdkError` mapping:
- `SdkError_Unauthenticated` → `triggerSessionExpired()` → `unauthenticated` → redirect `/login`
- `SdkError_ConnectionFailed` → `triggerServerLost()` → `serverUnselected` → redirect `/select/server`

Redirect rules live in `main.dart` `GoRouter.redirect`: `serverUnselected→/select/server`, `serverUninitialized→/guide/1`, `unauthenticated→/login` (`/login` and `/select/server` allowed), `authenticated→/home` (guide/select/login pages bounce to `/home`).

## ID / Type Conventions
- Rust `u64` maps to Dart `BigInt` (FRB-generated); route params and list items stay `int`, convert at the proxy boundary with `BigInt.from(...)`
- Examples: `resourceGet(rid: BigInt.from(widget.rid))`, `metadataQuery(depth: BigInt.from(4))`, `pageSize: BigInt.from(40)`
- Returned entity fields (`uid/lid/rid/did/tid/fid`) are already `BigInt`; compare via `BigInt.from(selfUid)`
- Placeholder values use `BigInt.zero`
- JWT uid parsing uses base64url decoding of the payload `sub` claim (standard base64 fails on URL-safe chars)

## SDK Proxy Signatures
- `_value<T>(Future<T> Function() fn)` → `Future<T>`: async with return value (the common case)
- `_void(Future<void> Function() fn)` → `Future<void>`: async without return value (delete/logout/enable-style calls)
- `_sync<T>(T Function() fn)` → `T`: synchronous (`setToken`, `getToken`, `logout`, `staticItem`)
- All three: run `fn` → on success `_syncRenewedToken()` persists a slide-renewed token back to `AuthController`/SharedPreferences → catch `SdkError_Unauthenticated`/`SdkError_ConnectionFailed`, fire the matching global event, rethrow → other errors propagate unchanged to the page's `catch`

## Getting Started
- Setup: `flutter pub get`
- Run: `flutter run`
- Debug builds wrap the app in `DevicePreview(enabled: true)` (`main.dart`): the app renders inside a device frame in debug; physical layout testing can be misleading
- Release (`kReleaseMode`) runs the app directly

## CI
`.github/workflows/flutter_build.yml`: push/PR to master/dev triggers android/ios/web/linux/macos/windows builds. format/analyze/test steps are continue-on-error (non-blocking) — run them locally before committing.
