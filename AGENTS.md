# Marginalia — Flutter app conventions

Read this before touching any file under `marginalia-mobile/`. The rules
here describe *exact* placement; do not invent new top-level folders or
re-introduce a `shared/` split.

---

## 1. Folder structure

Layer-based, flat. Every folder has one job. Do not subdivide further
without changing this document first.

```
lib/
├── main.dart                       # entry — ProviderScope + bootstrap
├── app/
│   └── theme/
│       ├── app_theme.dart          # ThemeData(light) / ThemeData(dark) factories
│       ├── tokens/                 # design-system primitives (mirrors design-system.md §15)
│       │   ├── colors.dart         # AppColors (raw hex) + AppColorsExtension (ThemeExtension)
│       │   ├── typography.dart     # AppTypography — Source Serif 4 · Inter · Newsreader
│       │   ├── spacing.dart        # AppSpacing — xs/sm/md/lg/xl/xxl/xxxl + pageHorizontal
│       │   └── radii.dart          # AppRadii — xs..xl + full
│       └── extensions/             # ThemeExtension subclasses beyond the colors one
│
├── core/                           # cross-cutting infra — NEVER imports from features
│   ├── dio_client.dart             # DioFactory + interceptors + ApiError + dioProvider
│   ├── storage/
│   │   ├── cookie_jar_storage.dart # (reserved) wrapper around PersistCookieJar
│   │   └── secure_storage.dart     # flutter_secure_storage wrapper
│   ├── widgets/                    # truly generic atoms (LoadingButton, EmptyState…)
│   ├── extensions/                 # BuildContext.appColors, DateTime.timeAgo, …
│   └── utils/                      # pure functions — formatters, parsers, etc.
│
├── models/                         # EVERY data model — flat, no subfolders.
│                                   # Entities (User, Book, …) AND request DTOs
│                                   # (LoginRequest, BookCreateRequest, …) live side by side.
│                                   # All Freezed + json_serializable.
│
├── providers/                      # Riverpod providers ONLY — one file per feature
│   ├── auth_provider.dart          # StateNotifier (AuthController) + StateNotifierProvider
│   └── state/                      # Freezed sealed unions describing controller state
│       └── auth_state.dart
│
├── services/                       # Business logic
│   ├── backend/                    # HTTP / Spring-Boot-facing — Dio under the hood
│   │   └── auth_service.dart       # one file per feature — HTTP per endpoint, returns
│   │                               # a model, lets ApiError propagate (no Result wrapper)
│   └── frontend/                   # client-only — validators, formatters, local rules
│       └── auth_validators.dart
│
├── screens/                        # All screen widgets, grouped by flow when natural
│   ├── welcome_screen.dart         # one-offs sit at the top
│   ├── auth/                       # login_screen.dart, register_screen.dart
│   └── onboarding/                 # onboarding_1.dart, onboarding_2.dart, onboarding_3.dart
│   # As features land, add: home/, library/, reading/, highlights/, search/,
│   # insights/, settings/, notifications/, subscription/. Same flat convention.
│
└── widgets/                        # Reusable widgets NOT in core/widgets
                                    # (domain-tinted — BookCover, HighlightCard, TagDot, …)
```

**No `features/`. No `shared/`.** A model used by 8 screens still lives in
`lib/models/`. A widget used by 6 screens still lives in `lib/widgets/`.
The flat tree is the whole point.

---

## 2. **MANDATORY — Figma first, code second**

> Before writing any screen file, you MUST inspect the corresponding Figma
> design. Code that doesn't match the Figma is wrong, even if it compiles
> and looks fine in the simulator.

### How to get the design before coding

1. **Read `marginalia-design/design-system.md` §15** for token names and exact
   values (colors, spacing, radii, typography). All values in code must bind
   to a token from `lib/app/theme/tokens/` — never hardcode a hex or pixel.
2. **Read `marginalia-design/screen-workflows.md`** for the flow logic — which
   buttons go where, what transitions happen, what state each surface starts in.
3. **Open the Figma file** to verify exact layout:
   - File: <https://www.figma.com/design/RJQrZcwI0cmVLZc4oBpStz/Marginalia-?node-id=1-2>
   - If the `figma` MCP server is available, call `get_design_context` /
     `get_screenshot` / `get_metadata` on the target frame.
   - If MCP isn't available, ask the user for a screenshot or a Figma node URL.

### What "match the Figma" means

- Every color uses `context.appColors.<token>` or `AppColors.tag<Name>` — never
  a raw `Color(0xFF…)` in a screen file.
- Every paddings/gaps uses `AppSpacing.<token>` — never a raw `16.0`.
- Every radius uses `AppRadii.brMd` (or whichever) — never `BorderRadius.circular(12)`.
- Every text style uses `AppTypography.<style>(color)` — never `TextStyle(fontSize: …)`.
- Light AND dark variants both verified before declaring a screen done.

If the Figma frame doesn't exist yet, **stop and tell the user** — do not
guess a layout.

---

## 3. State management — Riverpod + Freezed

- One provider file per feature: `providers/<feature>_provider.dart`. It holds
  the `StateNotifier` subclass (the controller, e.g. `AuthController`) AND its
  provider — there is no separate `_controller.dart`.
- Controllers extend `StateNotifier<TState>` where `TState` is a Freezed
  sealed union defined in `providers/state/<feature>_state.dart`.
- The corresponding provider is a `StateNotifierProvider`, named
  `<feature>Provider`, declared at the bottom of the provider file.
- The controller is the single place that `try/catch`es errors from the
  service: it calls `<feature>_service.dart`, lets a thrown `ApiError` surface,
  and maps it to an error state (e.g. `AuthUnauthenticated(message: e.message)`).
- Widgets read state via `ref.watch(<feature>Provider)` and call
  methods via `ref.read(<feature>Provider.notifier).<method>()`.
- Pattern-match on the sealed state with Dart `switch` expressions — do not
  use `when()` (we are not using the union-helper extension).

```dart
final auth = ref.watch(authProvider);
final loading = auth is AuthLoading;
final error = switch (auth) {
  AuthUnauthenticated(:final message) => message,
  _ => null,
};
```

---

## 4. Models — Freezed only

- Every file in `lib/models/` is a `@freezed class` with `fromJson`/`toJson`.
- File name = snake_case of the class name (`login_request.dart` → `LoginRequest`).
- After adding or editing any model:
  ```powershell
  dart run build_runner build --delete-conflicting-outputs
  ```
- For union types (UI state), use `@freezed sealed class …`.

---

## 5. Services — two directions

- `services/backend/` — anything that hits the Spring Boot API. **One file per
  feature**: `<feature>_service.dart`, class `<Feature>Service`. It calls the
  endpoint via `Dio`, parses the JSON into a model, and returns it. It does
  **not** translate or catch errors — Spring Boot already owns the business
  logic, so the client service is a thin data layer. A non-2xx becomes an
  `ApiError` (thrown by the interceptor in `dio_client.dart`) that propagates up
  to the controller. Expose a Riverpod `Provider` for the service at the bottom
  of the file. **No `_api.dart` + `_repository.dart` split, no `Result`/`Failure`.**
- `services/frontend/` — pure client logic. Validators, parsers, formatters.
  No `Dio`, no async I/O.

---

## 6. Networking

- Cookie-based auth. The backend sets `marg_tkn` (access, 30 min) and
  `marg_refresh` (refresh, 7 days) as HttpOnly cookies.
- `PersistCookieJar` keeps them across app restarts — silent re-login works.
- `AuthInterceptor` handles 401 on any non-`/auth/*` call: fires
  `POST /auth/refresh` once (serialized across concurrent failures), then
  retries the original request. If refresh itself fails, the 401 bubbles
  up and the controller routes the user to `/welcome`.
- Base URLs: `10.0.2.2:8080` on Android emulator, `localhost:8080` on iOS
  simulator. Set in `DioFactory.defaultBaseUrl`.

---

## 6a. **MANDATORY — backend is the source of truth**

> Whenever you write code that talks to the API — a new model in
> `lib/models/`, an endpoint call in `services/backend/`, a state shape
> that wraps a response — you MUST check the actual backend source at
> `marginalia-backend/dev/` first. Do not guess field names, types, or
> endpoint paths from memory.

### Where to look in `marginalia-backend/dev/src/main/java/com/marginalia/dev/`

| You need… | Look in… |
|---|---|
| Endpoint path, HTTP verb, request body type, response type, status codes | `controllers/<Feature>Controller.java` |
| Exact JSON shape of a request body (field names, validation rules) | `dto/<feature>/<…>Request.java` |
| Exact JSON shape of a response (field names, nullability, `@JsonInclude`) | `dto/<feature>/<…>Response.java` |
| What columns / types the DB actually stores | `entities/<Entity>.java` |
| What HTTP statuses you should expect on errors | `exceptions/GlobalExceptionHandler.java` |
| Auth/security boundaries (which routes need a session) | `security/SecurityConstants.java`, `security/SecurityConfig.java` |

### The discipline

- Field names in `lib/models/<x>.dart` match the backend DTO **exactly** —
  including casing (`displayName`, not `display_name`). Jackson on the backend
  uses camelCase by default; json_serializable on the client should match.
- If the backend marks a field optional (Java `Optional`, nullable type, or
  `@JsonInclude(NON_NULL)`), the Dart field is `String?` / `int?` / etc.
- If the backend uses `@Valid` with `@NotBlank` / `@Min` / `@Pattern` on a
  request DTO, mirror that in `services/frontend/<feature>_validators.dart`
  so the client refuses bad input before the round trip.
- Error responses come in the shape `{ status, error, message, timestamp }`
  produced by `GlobalExceptionHandler`. `ApiError.fromJson` already parses
  this — never reinvent it.

### If a backend file disagrees with this AGENTS.md or with `database-architecture.md`

The backend Java source wins. Update the doc to match — don't code to the doc.

---

## 7. Import paths

- Always relative imports inside `lib/` (`import '../../models/user.dart';`).
- Package imports for `package:flutter/`, `package:flutter_riverpod/`, etc.
- Group order: dart: → package: → relative.

---

## 8. Naming conventions

| Thing | Style | Example |
|---|---|---|
| File names | `snake_case.dart` | `login_request.dart` |
| Classes / types | `PascalCase` | `LoginRequest`, `AuthController`, `AuthService` |
| Variables / methods | `lowerCamelCase` | `authController`, `signIn()` |
| Constants (file-level) | `lowerCamelCase` | `defaultBaseUrl` |
| Token classes | `App<Thing>` | `AppColors`, `AppTypography`, `AppSpacing`, `AppRadii` |
| Providers | `<thing>Provider` | `dioProvider`, `authProvider` |

---

## 9. Commands you'll run

```powershell
# Once after cloning
flutter pub get

# Whenever you edit a Freezed model or state class
dart run build_runner build --delete-conflicting-outputs
# …or keep watching during active dev:
dart run build_runner watch --delete-conflicting-outputs

# Run on Android emulator (default)
flutter run

# Run on iOS simulator
flutter run -d ios

# Run for a specific device
flutter devices
flutter run -d <id>
```

---

## 10. Do / don't summary

| Do | Don't |
|---|---|
| Read design-system.md + the Figma frame before coding a screen | Invent layout from prose alone |
| Bind every color/spacing/radius/text to a token from `app/theme/tokens/` | Hardcode `Color(0xFF…)` or `16.0` in screens |
| Put **all** models in `lib/models/`, flat | Create per-feature `models/` subfolders |
| Put **all** providers in `lib/providers/` | Co-locate providers inside `screens/` |
| Use Freezed sealed unions for state | Hand-roll `enum + switch + fields` |
| Use relative imports inside `lib/` | Mix in absolute `package:marginalia/…` imports |
| Run `build_runner build` after every model change | Edit a `.freezed.dart` or `.g.dart` file by hand |

---

## 11. Tests run on the Windows host — no Impeller

`flutter test` executes on the Windows host, where Impeller is unavailable and
`ImageFilter.isShaderFilterSupported` is `false`. Any Impeller-only package or
fragment-shader effect (e.g. a shader-based "liquid glass") **never runs its
real render path under test** — and will crash the whole widget-test suite if it
has no fallback. So:

- Gate every shader path on `ImageFilter.isShaderFilterSupported` and provide a
  plain-Flutter fallback (`BackdropFilter`, a solid surface, …) for the `false`
  branch.
- A green test run only proves the **fallback** renders. The real shader look —
  and any Figma match — must be eyeballed on an Android/iOS emulator (Impeller is
  on by default there). Don't let "tests pass" stand in for visual verification.



  # don't do smoke test or any file of test , and don't run flutter clean , flutter run, flutter pub get ask me to do it 
