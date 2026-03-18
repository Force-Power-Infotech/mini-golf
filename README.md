# Mini Golf

Mini Golf is a Flutter app for running mini-golf games with OTP login, team creation, live scoring, and leaderboard views.

## What This Project Does

- Lets a user login with mobile number + OTP.
- Lets a user create a team and choose number of holes.
- Tracks player scores hole-by-hole.
- Saves score state locally and syncs totals to backend.
- Shows day-wise and team-wise leaderboard screens.

## Tech Stack

- Flutter (Dart)
- GetX (routing/navigation + helpers)
- Dio (HTTP client)
- GetStorage (local persistence)
- just_audio and confetti (UX effects)

## Run The App

1. Install Flutter SDK and ensure `flutter doctor` passes.
2. Install dependencies:

```bash
flutter pub get
```

3. Run:

```bash
flutter run
```

For web, you can pass a board id through URL query params:

```text
http://localhost:xxxxx/?boardId=YOUR_BOARD_ID
```

The app reads `boardId` from URL in `main.dart` and stores it for API calls.

## Project Layout

- `lib/main.dart`: app entry, reads `boardId` query param, starts `GetMaterialApp`.
- `lib/routes/`: named routes and route generator.
- `lib/pages/`: feature screens (login, home, play, scoring, leaderboard).
- `lib/connection/`: shared API service and request/response logging.
- `lib/api.dart`: backend base URL.
- `lib/class/`: response/data model classes.
- `lib/storage/`: local persistence wrapper around GetStorage.

## API And Backend

### Where The Backend Is

The app currently uses one backend endpoint hosted as a Google Apps Script web app.

- Base URL lives in `lib/api.dart` as `Api.baseUrl`.
- Most app API calls are `POST` form-data requests to this same URL.
- Behavior is selected by sending a `q` parameter (action name).

### API Client In App (Who Does What)

- `lib/connection/connection.dart`:
	- `ApiService.post(...)` sends `FormData` requests.
	- Handles 302 redirects by following `location` header.
	- Adds request/response/error logging.
- `lib/connection/interceptor.dart`:
	- Extra formatted logging interceptor class (available for use).
- `lib/api.dart`:
	- Single source of truth for backend URL.

### Backend Actions Used By The App

All actions below are sent to the same endpoint with `q=<action>`.

| `q` action | Called from | Purpose | Main payload fields | Expected response fields |
|---|---|---|---|---|
| `login` | `LoginScreen._sendOtp()` | Request OTP for mobile number | `mobileNo` | `error`, `message`, `userID` |
| `verifyOTP` | `LoginScreen._submitOtp()` | Validate OTP and fetch user profile | `userID`, `otp` | `error`, `message`, user fields (`userID`, `name`, etc.) |
| `modifyUsername` | `Homescreen.nameapi()` | Update username after first login | `userID`, `username` | `error`, `message` |
| `createTeam` | `PlayNowScreen._createTeam()` | Create game team and session config | `createdBy`, `members`, `numberOfHoles`, `boardId` | `error`, `message`, `teamId`, `members` |
| `scoring` | `ScoringScreen` methods | Initialize/update score values | `uid`, `teamId`, `score` | `error`, `message` |
| `dayWiseLeaderboard` | `LeaderBoardScreen.fetchLeaderboardData()` | Fetch overall/day leaderboard | none besides `q` | `error`, `scores` |
| `leaderboard` | `GroupWiseLeaderboard.fetchLeaderboardData()` | Fetch leaderboard for a team | `teamId` | `error`, `scores` |

Notes:
- `scores` entries are parsed with fields like `uid`, `userName`, `score`, `status`, `lastUpdated`.
- Team data is parsed into `TeamClass` and player/member model objects.

### Data Flow (How It Works End To End)

1. User enters mobile number.
2. App sends `q=login` to request OTP.
3. User enters OTP.
4. App sends `q=verifyOTP`, then stores user object in local storage.
5. User creates team from Play Now.
6. App sends `q=createTeam`, stores returned team object locally.
7. Scoring screen sends initial `q=scoring` score records and later score updates.
8. Leaderboard screens fetch either day-wise or team-wise data from backend.

### Local Storage And Session State

`lib/storage/get_storage.dart` stores:

- `user`: logged-in user payload
- `team`: current team payload
- `boardId`: URL query value captured at startup
- `game_scores` / `scores`: locally cached score data

## Important Implementation Notes

- `main.dart` imports `dart:html`, which is web-specific.
- Leaderboard HTML files in `lib/pages/*.html` also call the same Google Apps Script endpoint directly via JavaScript `fetch`.
- Routing is centralized in `lib/routes/routes_generator.dart`.

## If You Need To Change Backend

1. Update `Api.baseUrl` in `lib/api.dart`.
2. Keep current `q` contract in your backend, or update matching calls in screen methods.
3. Validate response JSON keys used by model parsing:
	 - `UserClass.fromJson`
	 - `TeamClass.fromJson`
	 - leaderboard parsing in `leader_board_screen.dart` and `group_wise_leaderboard.dart`

## Development Checklist

- Run static analysis:

```bash
flutter analyze
```

- Run tests:

```bash
flutter test
```
