# Mini Golf (Go Putt)

Flutter app for managing mini-golf gameplay, teams, live scoring, and leaderboards.

## Overview

This project includes:

- Mobile/web Flutter client (main app in `lib/`)
- Local storage for session/team/score state (`get_storage`)
- Remote API integration via HTTP POST (`dio`)
- Two HTML leaderboard pages used for display screens (`lib/pages/*.html`)

## Tech Stack

- Flutter (Dart)
- State/navigation: `get`
- HTTP client: `dio`
- Local persistence: `get_storage`
- Audio: `just_audio`

## Project Structure

Key folders:

- `lib/main.dart`: app entrypoint, reads `boardId` from URL query params
- `lib/routes/`: route constants and route generator
- `lib/pages/`: screens (login, home, play, scoring, leaderboards)
- `lib/connection/connection.dart`: API service wrapper over Dio
- `lib/api.dart`: main API base URL constant
- `lib/storage/get_storage.dart`: local persistence helper
- `lib/class/`: response/data models

## Run Locally

Prerequisites:

- Flutter SDK (3.x)
- Dart SDK (as required by `pubspec.yaml`)

Commands:

```bash
flutter pub get
flutter run
```

For web:

```bash
flutter run -d chrome
```

## App Flow

1. App starts at `GetStartedScreen`.
2. User logs in with mobile number (OTP flow; OTP currently auto-filled as `2020` in client logic).
3. User can create a team, enter scores per player/hole, and save scores.
4. Leaderboard screens fetch score rankings from backend.

## API and Backend

This section explains the backend integration clearly in terms of what, where, who, and how.

### What

The app talks to remote backend services for:

- Login and OTP verification
- Team creation
- Score submission
- Leaderboard retrieval
- Slot reservation lookup
- Username updates

### Where

Backend calls are split across these base endpoints:

1. Main app API (`q` action pattern):
	 - `https://app.forcempower.com/minigolf/api/v1/index.php`
2. Booking endpoints (separate PHP routes):
	 - `https://app.forcempower.com/booking/api/fetch_reservations.php`
	 - `https://app.forcempower.com/booking/api/modify_username.php`
3. Leaderboard display pages (HTML pages) call a Google Apps Script endpoint:
	 - `https://script.google.com/macros/s/AKfycbwy-p8bwLNYWLzfs7UYDP24MTtQN9LWgPg3Gxiv_q3iIGFWfMoO0tja3M2BfoCDS7ASww/exec`

### Who

- Client (this repo): Flutter UI, local storage, request orchestration.
- Backend (external, not in this repo): PHP/API services hosted under `app.forcempower.com` and Google Apps Script endpoint for display leaderboards.

Important: there is no server-side backend source code in this repository.

### How

- API wrapper: `ApiService` in `lib/connection/connection.dart`
- Request method: mostly `POST` with `FormData`
- Main action routing: send `q` field in body to indicate backend action
- Timeout: 90 seconds connect/receive
- Response handling pattern: screens check `statusCode == 200` and `data['error'] == false`

## API Action Map (From Client Code)

Main API (`Api.baseUrl`):

- `q=login`
	- Used in `LoginScreen` and company-user creation flow in `HomeScreen`
	- Params seen: `mobileNo`, optional `companyName`
- `q=verifyOTP`
	- OTP verification in `LoginScreen`
	- Params: `userID`, `otp`
- `q=createTeam`
	- Team creation in `PlayNowScreen`
	- Params: `createdBy`, `members`, `companyNames`
- `q=scoring`
	- Score save in `ScoringScreen`
	- Params: `uid`, `teamId`, `score`, `lastEnd`, `shot_type`
- `q=dayWiseLeaderboard`
	- Day leaderboard in `LeaderBoardScreen`
- `q=leaderboard`
	- Team-wise leaderboard in `GroupWiseLeaderboard`
	- Params: `teamId`

Non-`Api.baseUrl` endpoints used directly:

- `POST /booking/api/fetch_reservations.php`
	- Called in `HomeScreen` for slot availability
	- Params: `date`, `timeSlot`
- `POST /booking/api/modify_username.php`
	- Called in `HomeScreen` for profile name update
	- Params: `userID`, `username`

HTML leaderboard pages in `lib/pages/`:

- `leaderboard.html` posts `q=dayWiseLeaderboard`
- `finalleaderboard.html` posts `q=latestLeaderboard`

## Storage

`lib/storage/get_storage.dart` stores:

- `user`: authenticated user payload
- `team`: active team payload
- `boardId`: URL query parameter persisted at startup
- score snapshots for in-progress gameplay

## Notes and Risks

- OTP value `2020` is currently hardcoded in client flow for verification trigger.
- API base URLs are hardcoded in source.
- HTML pages and Flutter app do not fully share a single endpoint strategy; they use different backend origins.

## Suggested Improvements

- Move all endpoint URLs to environment-based config.
- Remove hardcoded OTP behavior from client logic.
- Add centralized API contract docs (request/response examples).
- Add unit/widget tests for login, scoring, and leaderboard parsing.
