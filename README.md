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

This section documents the backend integration in terms of **what** the backend does, **where** things live (URLs and files), **who** is responsible, and **how** the calls are made.

### What (backend responsibilities)

The Flutter app talks to remote backend services for:

- Login and OTP verification
- Team creation and management
- Score submission and updates
- Day-wise and group-wise leaderboard retrieval
- Slot reservation lookup
- Profile / username updates

### Where (URLs and code locations)

**Backend URLs**

1. Main app API (action routed via `q` field):
	- `https://app.forcempower.com/minigolf/api/v1/index.php`
2. Booking endpoints (separate PHP routes):
	- `https://app.forcempower.com/booking/api/fetch_reservations.php`
	- `https://app.forcempower.com/booking/api/modify_username.php`
3. Leaderboard display pages (HTML pages) call a Google Apps Script endpoint:
	- `https://script.google.com/macros/s/AKfycbwy-p8bwLNYWLzfs7UYDP24MTtQN9LWgPg3Gxiv_q3iIGFWfMoO0tja3M2BfoCDS7ASww/exec`

**Client-side code locations**

- `lib/api.dart` – defines `Api.baseUrl` (main app API URL).
- `lib/connection/connection.dart` – `ApiService` wrapper over Dio (`get` / `post` helpers, timeouts, loader handling).
- `lib/connection/interceptor.dart` – `LoggingInterceptors` used for structured request/response/error logging.
- `lib/pages/` – individual screens that build request bodies and call `ApiService`.
- `lib/pages/leaderboard.html`, `lib/pages/finalleaderboard.html` – HTML leaderboard pages that post to the backend/Apps Script.

### Who (responsibility split)

- **Client (this repo)**: Flutter UI, navigation, validation, local storage (user/team/board state), and orchestration of HTTP requests via `ApiService`.
- **Backend (external, not in this repo)**: PHP/API services hosted under `app.forcempower.com` plus a Google Apps Script endpoint that powers the public leaderboard displays.

There is **no server-side backend source code** in this repository; only the Flutter/web client and static HTML leaderboard pages.

### How (request / response flow)

- **HTTP client**: Dio, configured in `ApiService` with 90s connect/receive timeouts and interceptors.
- **Action routing**: most requests send a `q` field in the body to tell the PHP backend which action to execute (e.g. `q=login`, `q=scoring`).
- **Data format**: `POST` requests send data as `FormData.fromMap`; some `GET` requests use query parameters.
- **Loading UX**: `ApiService` shows a loader via `AppWidgets.showLoader()` before sending a request and hides it when the response or error is received.
- **Logging**: `LoggingInterceptors` (and the inline interceptor in `ApiService`) log URI, method, headers, body, status code, and error details for easier debugging.
- **Response pattern**: screens typically expect HTTP status `200` and a JSON payload where `error == false` indicates success, then map fields into local models or storage.

### Endpoint overview (from client code)

**Main API (Api.baseUrl)**

- `q=login`
	- Used in login and company-user creation flows.
	- Example params: `mobileNo`, optional `companyName`.
- `q=verifyOTP`
	- OTP verification after login.
	- Example params: `userID`, `otp`.
- `q=createTeam`
	- Team creation when starting a new game.
	- Example params: `createdBy`, `members`, `companyNames`.
- `q=scoring`
	- Save scores for a team and hole.
	- Example params: `uid`, `teamId`, `score`, `lastEnd`, `shot_type`.
- `q=dayWiseLeaderboard`
	- Fetch day-wise leaderboard data.
- `q=leaderboard`
	- Fetch group/team-wise leaderboard data.
	- Example params: `teamId`.

**Non-Api.baseUrl endpoints used directly**

- `POST https://app.forcempower.com/booking/api/fetch_reservations.php`
	- Used for slot availability lookup.
	- Example params: `date`, `timeSlot`.
- `POST https://app.forcempower.com/booking/api/modify_username.php`
	- Used for profile/username updates.
	- Example params: `userID`, `username`.

**HTML leaderboard pages (lib/pages/)**

- `leaderboard.html` – posts `q=dayWiseLeaderboard` and renders a day-wise leaderboard display.
- `finalleaderboard.html` – posts `q=latestLeaderboard` and renders the final/overall leaderboard.

## API Reference

This section documents the client-side view of each API the app calls. Field names and shapes are taken from the Flutter code; the real backend may include additional fields.

### Auth: Login (q=login)

- **URL**: `POST https://app.forcempower.com/minigolf/api/v1/index.php`
- **Used in**: Login flow, company user creation.
- **Request body (FormData)**

	```json
	{
		"q": "login",
		"mobileNo": "<string>",       // user mobile or generated phone
		"companyName": "<string>"    // optional, used when creating company users
	}
	```

- **Success response (as used by client)**

	```json
	{
		"error": false,
		"message": "<string>",
		"userID": "<string>",
		"mobileNo": "<string>",
		"otp": "<string>",
		"name": "<string>",
		"lastLogin": "<string>",
		"active": "<string>",
		"companyName": "<string|null>"
	}
	```

### Auth: Verify OTP (q=verifyOTP)

- **URL**: `POST https://app.forcempower.com/minigolf/api/v1/index.php`
- **Used in**: OTP verification after login.
- **Request body (FormData)**

	```json
	{
		"q": "verifyOTP",
		"userID": "<string>",
		"otp": "<string>"      // in client flow, often "2020"
	}
	```

- **Success response (as used by client)**

	Same structure as login (mapped into `UserClass`), e.g.:

	```json
	{
		"error": false,
		"message": "<string>",
		"userID": "<string>",
		"mobileNo": "<string>",
		"otp": "<string>",
		"name": "<string>",
		"lastLogin": "<string>",
		"active": "<string>",
		"companyName": "<string|null>"
	}
	```

### Teams: Create Team (q=createTeam)

- **URL**: `POST https://app.forcempower.com/minigolf/api/v1/index.php`
- **Used in**: Play Now / create team flow.
- **Request body (FormData)**

	```json
	{
		"q": "createTeam",
		"createdBy": "<string>",          // userID of creator
		"members": "[\"Player 1\", \"Player 2\"]",       // JSON-like string
		"companyNames": "[\"Company A\", \"Company B\"]" // JSON-like string
	}
	```

- **Success response (as used by client)**

	```json
	{
		"error": false,
		"message": "<string>",
		"teamId": "<string>",
		"createdBy": "<string>",
		"members": [
			{ "userID": "<string>", "userName": "<string>" }
		],
		"createDateTime": "<string>"
	}
	```

### Scoring: Save Scores (q=scoring)

- **URL**: `POST https://app.forcempower.com/minigolf/api/v1/index.php`
- **Used in**: Scoring screen when saving scores per player.
- **Request body (per player, FormData)**

	```json
	{
		"q": "scoring",
		"uid": "<string>",         // player userID
		"teamId": "<string>",
		"score": <number>,          // total score
		"lastEnd": <number>,        // last completed hole (1-based)
		"shot_type": "swing" | "putt"
	}
	```

- **Success response (as used by client)**

- Client only checks for HTTP `200`; any body with `error == false` is treated as success (exact fields are not strongly typed in code).

### Leaderboards: Day-wise (q=dayWiseLeaderboard)

- **URL**: `POST https://app.forcempower.com/minigolf/api/v1/index.php`
- **Used in**: Day-wise leaderboard Flutter screen and HTML leaderboard page.
- **Request body (FormData)**

	```json
	{
		"q": "dayWiseLeaderboard"
	}
	```

- **Success response (as used by client)**

	```json
	{
		"error": false,
		"message": "<string>",
		"scores": [
			{ /* mapped into LeaderboardModel.fromJson(...) */ }
		]
	}
	```

### Leaderboards: Group / Team-wise (q=leaderboard)

- **URL**: `POST https://app.forcempower.com/minigolf/api/v1/index.php`
- **Used in**: Group-wise leaderboard Flutter screen.
- **Request body (FormData)**

	```json
	{
		"q": "leaderboard",
		"teamId": "<string>"
	}
	```

- **Success response (as used by client)**

	```json
	{
		"error": false,
		"message": "<string>",
		"scores": [
			{ /* mapped into LeaderboardModel.fromJson(...) */ }
		]
	}
	```

### Leaderboards: Final (q=latestLeaderboard)

- **URL**: Google Apps Script endpoint (from HTML pages).
- **Used in**: `finalleaderboard.html` static page.
- **Request body**

	```json
	{
		"q": "latestLeaderboard"
	}
	```

- **Response**: consumed by client-side JavaScript in the HTML; structure is not fully typed in Dart but expected to be a list of final rankings.

### Booking: Fetch Reservations

- **URL**: `POST https://app.forcempower.com/booking/api/fetch_reservations.php`
- **Used in**: Home screen slot availability check.
- **Request body (form-encoded)**

	```json
	{
		"date": "YYYY-MM-DD",
		"timeSlot": "HH:MM AM/PM"
	}
	```

- **Success response (as used by client)**

	```json
	{
		"error": false,
		"message": "<string>",
		"data": [
			{ /* mapped into SlotDetails.fromJson(...) */ }
		]
	}
	```

### Booking: Modify Username

- **URL**: `POST https://app.forcempower.com/booking/api/modify_username.php`
- **Used in**: Updating displayed player name from the home screen.
- **Request body (FormData)**

	```json
	{
		"userID": "<string>",
		"username": "<string>"
	}
	```

- **Success response (as used by client)**

	```json
	{
		"error": false,
		"message": "<string>"
	}
	```

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
