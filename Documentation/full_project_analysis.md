# DSV360 — Full Project Analysis

> Flutter project. Backend: Zoho Catalyst Serverless. App Name: DSV360.
> This document covers every concept in the codebase — pages, features, libraries, APIs, data flow, Catalyst integration, and authentication.

---

## 1. PROJECT OVERVIEW

DSV360 is a **project management + HR mobile app** built in Flutter. It connects to a **Zoho Catalyst** serverless backend. Employees, managers, and admins can manage projects, tasks, issues, leaves, attendance, time entries, feedback, and more — all from one app.

**Tech Stack:**
- Flutter (Dart) — frontend
- Zoho Catalyst — backend (serverless functions, auth, token, user management)
- Riverpod — state management
- Dio + http — HTTP clients
- `zcatalyst_sdk` — Zoho Catalyst Flutter SDK

---

## 2. APP ENTRY POINT — `main.dart`

- `WidgetsFlutterBinding.ensureInitialized()` — ensures Flutter is ready.
- `AppInitManager.instance.initCatalyst()` — initializes Zoho Catalyst SDK **before the app starts** (singleton, runs only once).
- `ProviderScope` — wraps the entire app so Riverpod works everywhere.
- `MyApp` — builds `MaterialApp` with light/dark theme using `themeController`.
- First screen shown: `SplashScreen`.
- Direct route registered: `/settings → SettingsPage`.

---

## 3. ALL PAGES (SCREENS) IMPLEMENTED

### 3.1 Splash Screen (`views/splash/splash_screen.dart`)
- Shows app logo with **fade + slide animation** (2 seconds).
- After 3 seconds, calls `AppInitManager.instance.catalystApp.isUserLoggedIn()`.
- **If logged in:**
  - Fetches Catalyst user via `AuthManager.instance.fetchUser()`.
  - Converts to `ActiveUserModel` and stores in Riverpod (`activeUserRepositoryProvider`).
  - Fetches user profile via `UserManager.instance.fetchUserProfile(userId)`.
  - Fetches access token via `TokenManager.instance.getToken()`.
  - Navigates to `DashboardPage`.
- **If not logged in:** Navigates to `WelcomePage`.
- On any error: falls back to `WelcomePage`.

### 3.2 Welcome Page (`views/welcome/welcome_page.dart`)
- Shows app logo + welcome message + tagline.
- Single **Login** button → calls `AppInitManager.instance.catalystApp.login()`.
  - This triggers Zoho Catalyst's OAuth login flow (opens browser/webview).
  - On success → navigates to `LoadingPage`.
  - On failure → shows a SnackBar error.

### 3.3 Loading Page (`views/auth/loading_page.dart`)
- Shown right after login (post-OAuth redirect).
- Shows a spinner while:
  1. Fetching user details: `AuthManager.instance.fetchUser()`.
  2. Fetching user profile: `UserManager.instance.fetchUserProfile(user.id)`.
  3. Fetching token: `TokenManager.instance.getToken()`.
- On success → `DashboardPage`.
- On failure → back to `WelcomePage`.

### 3.4 Dashboard Page (`views/dashboard/dashboard_page.dart`)
Main home screen. Components:
- **AppBar:** Logo, "DSV360" title, notification bell icon, profile avatar icon.
- **Drawer:** Side navigation (AppDrawer).
- **Connectivity check:** If no internet → shows `GlobalError` widget.
- **Pull-to-refresh** supported.
- Data loaded from `dashboardDataProvider` (Riverpod FutureProvider):
  - Total users count, project count, completed project count, issue count, task count.
  - Year-wise task data (open/in-progress/closed).
  - Month-wise project data for the year.
- Sub-widgets shown:
  - `DashboardTitle` — greeting with user name and date.
  - `StatGrid` — 4 stat cards (users, projects, completed projects, issues).
  - `TopHeader` — header for charts section.
  - `TaskStatusCard` — doughnut/pie chart of task statuses (uses `fl_chart`).
  - `ProjectAnalyticsCard` — bar chart of monthly project data (uses `fl_chart`).

### 3.5 Projects Screen (`views/projects/projects_screen.dart`)
- Lists all projects.
- **Admin:** sees all projects.
- **Regular user:** sees only their assigned projects.
- Search functionality to filter projects.
- Each project shown in a `ProjectCard`.
- Tap a project → `ProjectDetailsDialog` (modal sheet).
- FAB → `AddProjectDialog` (add new project).

### 3.6 Project Details Dialog (`views/projects/project_details_dialog.dart`)
- Shows: project name, status, client, start/end dates, assigned to, owner, description.
- Lists tasks under the project.
- Shows time entries for the project.
- Attachment support.

### 3.7 Tasks Screen (`views/task/tasks_screen.dart`)
- Lists tasks based on role:
  - **Admin:** all tasks (endpoint: `/tasks`).
  - **Manager:** tasks from all their projects (endpoint: `/tasks/project`).
  - **Regular user:** only their assigned tasks (endpoint: `/tasks/employee/{userId}`).
- Filterable by status, project, etc.
- FAB → `AddTaskDialog` to create a new task.
- Tap task → `TaskDetailsDialog`.

### 3.8 Task Details Dialog (`views/task/task_details_dialog.dart`)
- Shows: task name, status, priority, project, assignees, due date, description.
- Timer control (start/stop timer for the task).
- Opens `TimeEntriesScreen` to see time logs.
- Attachments tab via `TaskAttachmentsModalSheet`.

### 3.9 Issues Screen (`views/issues/issues_screen.dart`)
- Lists issues.
  - **Admin:** all issues (endpoint: `/issue`).
  - **Regular user:** issues assigned to them (endpoint: `/assignissue/{userId}`).
- Tap → `IssueDetailsModalSheet`.
- FAB → `AddIssueFormScreen`.

### 3.10 Add Issue Form Screen (`views/issues/add_issue_form_screen.dart`)
- Form to create a new issue: name, description, severity, status, project, assignee, due date.
- Assignee selection via `AssigneeModal`.

### 3.11 People Page (`views/people/people_page.dart`)
Tabbed page. Tabs depend on role:
- **Regular user (4 tabs):** Overview, Attendance, Leaves, Time Logs.
- **Manager (6 tabs):** Overview, Attendance, Leaves, Time Logs, Attendance Tracker, Leave Approval.

Tabs details:
- **Overview:** Shows leave summary (paid/casual/sick/unpaid counts), pending tasks list, check-in/check-out button with geolocation.
- **Attendance:** Date-range filtered attendance dashboard from API.
- **Leaves:** View leave history, apply for leave via `ApplyEditLeavePage`.
- **Time Logs:** View time logs for a date range.
- **Attendance Tracker (Manager only):** View attendance of other users.
- **Leave Approval (Admin/Manager only):** Approve or reject leave requests.
- Check-in/Check-out uses GPS (`geolocator` package), device name, timestamp, latitude/longitude.

### 3.12 Apply / Edit Leave Page (`views/people/apply_edit_leave_page.dart`)
- Form to request a new leave or edit an existing one.
- Fields: leave type, start date, end date, reason, leave count.
- Calls API to submit.

### 3.13 Leave Details Page (`views/people/leave_details_page.dart`)
- Shows full details of a specific leave request.
- For managers/admins: shows approve/reject buttons.

### 3.14 Holiday Calendar Page (`views/people/holiday_calendar_page.dart`)
- Calendar showing company holidays by region/city.
- Regions supported: Mumbai, Pune, Vapi, Ambasamudram, and more.
- Data is **hardcoded mock data** (not from API yet).

### 3.15 Profile Page (`views/profile/profile_page.dart`)
- Shows logged-in user's profile:
  - Cover photo (from `userProfile.coverLink` or default Unsplash image).
  - Profile avatar (from `userProfile.profileLink` or default).
  - Name, email, role.
  - `AboutMe` section: skills, bio, certifications, education.
  - Badges earned.
- Logout button: calls `AppInitManager.instance.catalystApp.logout()` → navigates to `WelcomePage`, clears token (`TokenManager.clearToken()`).

### 3.16 Notifications Page (`views/notifications/notification_page.dart`)
- Shows a list of demo/sample notifications (hardcoded, not real-time yet).
- Types: Leave Approved, Leave Rejected, Task Assignment, Attendance Verified, Payroll Update, Meeting Reminder, Training Completed, Shift Update.
- Clearly labeled "This is not your real notification."

### 3.17 Settings Page (`views/settings/settings_page.dart`)
- Single toggle: **Dark Mode / Light Mode**.
- Uses `themeController.themeMode` (ValueNotifiable).
- Switch changes the theme app-wide immediately.

### 3.18 DSV AI Page (`views/ai/dsv_ai_page.dart`)
- Chat interface to interact with AI models.
- Two modes:
  - **AI Model:** Send text/image prompts to LLM models.
    - Text Model: `crm-di-qwen_text_14b-fp8-it`
    - Code Model: `crm-di-qwen_coder_7b-it`
    - Vision Model: `VL-Qwen2.5-7B` (supports image upload)
  - **RAG Mode:** Document-grounded Q&A bots.
    - Available bots: HR Bot, Vedanta, Finance Bot.
- Image picker (from gallery) for vision model.
- Scrollable chat history with user and bot bubbles.
- State: `aiLoadingProvider`, `aiModeProvider`, `aiModelProvider`, `aiImagesProvider`.

### 3.19 Accounts Page (`views/accounts/accounts_page.dart`)
- Lists client organizations (`/clientOrg` endpoint).
- Search/filter by name.
- FAB → `AddEditAccountsPage` (add new account).
- Tap → edit account.

### 3.20 Add/Edit Accounts Page (`views/accounts/add_edit_accounts_page.dart`)
- Form to add or update a client organization record.

### 3.21 Client Contacts Page (`views/clients/client_contacts_page.dart`)
- Lists contact persons associated with client organizations (`/contact` endpoint).
- Search functionality.
- FAB → `AddClientContactsPage`.

### 3.22 Add Client Contacts Page (`views/clients/add_client_contacts_page.dart`)
- Form to add a new client contact: name, email, phone, organization.

### 3.23 Badges Page (`views/badges/badges_page.dart`)
- Lists all users with their assigned DSV badges.
- Badges system: Bronze, Silver, Gold, Platinum, Diamond, Titanium tiers.
- SpeedDial FAB with two options:
  - Add/Edit a badge → `AddEditBadgePage`.
  - Assign badge to a user → `AssignBadgesPage`.

### 3.24 Add/Edit Badge Page (`views/badges/add_edit_badge_page.dart`)
- Form to create or update a badge definition.

### 3.25 Assign Badges Page (`views/badges/assign_badges_page.dart`)
- Select a user and assign a specific badge to them.

### 3.26 Users Page (`views/users/users_page.dart`)
- Lists all users in the organization (from `/batchProfile` endpoint).
- Search by name/email.
- FAB → `AddEditUserPage`.
- Tap a user → `UserDetailsPage`.

### 3.27 User Details Page (`views/users/user_details_page.dart`)
- Shows full profile of a selected user.

### 3.28 Add/Edit User Page (`views/users/add_edit_user_page.dart`)
- Form to add or edit a user's details.

### 3.29 Feedbacks Screen (`views/feedback/feedbacks_screen.dart`)
- Lists all feedback entries (`/feedback` endpoint).
- Searchable.
- FAB → `FeedbackFormScreen`.
- Tap → `FeedbackDetailScreen`.

### 3.30 Feedback Form Screen (`views/feedback/feedback_form_screen.dart`)
- Form to submit a new feedback.

### 3.31 Feedback Detail Screen (`views/feedback/feedback_detail_screen.dart`)
- Shows full content of a single feedback item.

### 3.32 Time Entries Screen (`views/time_entry/time_entries_screen.dart`)
- Lists time entries for a specific task/project.
- Filters: date range (from/to), billable vs non-billable.
- Shows total time logged.
- FAB → `AddTimeEntryDialog`.

### 3.33 Add Time Entry Dialog (`views/time_entry/add_time_entry_dialog.dart`)
- Form to manually add a time entry: task, project, date, start time, end time, description, billable toggle.

### 3.34 Attachment View Screen (`views/attachments/attachment_view_screen.dart`)
- Full-screen viewer for attachments.
- Supports **images** (using Flutter's `InteractiveViewer`) and **PDFs** (using `syncfusion_flutter_pdfviewer`).

### 3.35 Teams Page (`views/teams/teams_page.dart`)
- Placeholder — shows "Coming Soon" text. Not yet implemented.

---

## 4. ALL LIBRARIES / PACKAGES USED

| Package | Purpose |
|---|---|
| `flutter_riverpod: ^2.6.1` | State management (providers, notifiers, FutureProviders) |
| `riverpod_annotation: ^2.6.0` | Code generation annotations for Riverpod |
| `riverpod_generator: ^2.6.0` | Build runner generator for Riverpod |
| `dio: ^5.9.0` | HTTP client (primary — used in `DioClient`) |
| `http: ^1.1.0` | HTTP client (secondary — used in some repositories) |
| `go_router: ^17.0.0` | Navigation (imported but routing done via `Navigator` manually; `routes.dart` is empty) |
| `flutter_svg: ^2.2.2` | SVG image rendering |
| `intl: ^0.20.2` | Date/number formatting |
| `json_annotation: ^4.9.0` | JSON serialization annotations |
| `json_serializable: ^6.9.5` | Code generation for JSON parsing |
| `freezed_annotation: ^3.1.0` | Immutable data classes |
| `fl_chart: ^1.1.1` | Charts (pie/doughnut chart for task status, bar chart for project analytics) |
| `url_launcher: ^6.3.2` | Open URLs in browser |
| `syncfusion_flutter_pdfviewer: ^32.1.22` | In-app PDF viewing for attachments |
| `flutter_speed_dial: ^7.0.0` | Floating Action Button with multiple child actions (used in Badges page) |
| `zcatalyst_sdk: ^2.2.1` | Zoho Catalyst SDK — authentication, token, user management |
| `file_picker: ^8.0.0` | Pick files from device (attachments) |
| `image_picker: ^1.2.1` | Pick images from gallery/camera (AI page, profiles) |
| `connectivity_plus: ^7.0.0` | Monitor internet connection status |
| `geolocator: ^14.0.2` | Get device GPS location (for check-in/check-out) |
| `cupertino_icons: ^1.0.8` | iOS-style icons |
| `build_runner: ^2.4.9` | Code generation runner |
| `flutter_lints: ^5.0.0` | Lint rules |

---

## 5. HOW ZOHO CATALYST IS IMPLEMENTED

Catalyst is the **entire backend** for this app. Here is how it's integrated:

### 5.1 Initialization (`core/constants/init_zcatalyst_app.dart`)
- `AppInitManager` is a **singleton** class.
- `initCatalyst()` is called in `main()` before `runApp()`.
- It calls `ZCatalystApp.init(environment: catalystEnv)`.
  - Environment is controlled by `ENVIRONMENT.environment` string in `environment.dart`.
  - `"DEVELOPMENT"` → `ZCatalystEnvironment.DEVELOPMENT`.
  - `"PRODUCTION"` → `ZCatalystEnvironment.PRODUCTION`.
- After init, `ZCatalystApp.getInstance()` is stored as `app`.
- Provides `AppInitManager.instance.catalystApp` to the rest of the app.

### 5.2 Login / Logout (OAuth via Catalyst)
- **Login:** `AppInitManager.instance.catalystApp.login()`
  - This opens Zoho's OAuth login page (browser or webview).
  - After user logs in, Catalyst handles the callback and stores the session internally.
- **Logout:** `AppInitManager.instance.catalystApp.logout()` (called from profile page).
- **Check if logged in:** `AppInitManager.instance.catalystApp.isUserLoggedIn()` (returns `bool`).

### 5.3 User Fetching (`core/constants/auth_manager.dart`)
- `AuthManager` is a **singleton**.
- `fetchUser()` calls `app.getCurrentUser()` which returns `ZCatalystUser`.
- `ZCatalystUser` contains: `id`, `firstName`, `lastName`, `emailId`, `role`, `zaaid` (org ID), `userType`, etc.
- The user is stored in `AuthManager.instance.currentUser` for global access.

### 5.4 Access Token (`core/constants/token_manager.dart`)
- `TokenManager` is a **singleton**.
- `getToken()` calls `app.getAccessToken()` — returns the current OAuth access token.
- Has a **race condition guard**: if a token fetch is already in progress and multiple calls come in simultaneously, they all wait for the same ongoing fetch (using `_fetchingFuture`).
- The token is cached in `_accessToken`.
- `clearToken()` resets `_accessToken` to `null` (used on logout).
- This token is added to every API request header: `Authorization: Zoho-oauthtoken <token>`.

### 5.5 Role-Based Access via Catalyst User
- `ZCatalystUser` has a `role` field with a `name` property.
- `IsHaveAccess.instance.isAdmin` → checks if `user?.role?.name == 'Admin'`.
- `IsHaveAccess.instance.isManager` → checks if role name contains "manager" (case-insensitive).
- Used throughout the app to show/hide features, select different API endpoints, and control tab counts.

### 5.6 Catalyst Serverless Functions (Backend)
All API calls go to Catalyst Serverless Function endpoints under the path pattern:
`time_entry_management_application_function/<function_name>`

The base server URL:
- **Development:** `https://project-management-60040289923.development.catalystserverless.in/server/`
- **Production:** `https://project.dsv360.ai/server/`

There is also the AI service at `ai_service/api/...` (same base URL).

---

## 6. HOW AUTHENTICATION WORKS (STEP BY STEP)

```
App Start
  ↓
main() → AppInitManager.initCatalyst()   [Catalyst SDK initialized once]
  ↓
SplashScreen (3 second timer)
  ↓
catalystApp.isUserLoggedIn() ?
  ├── YES →
  │     AuthManager.fetchUser()           [Gets ZCatalystUser]
  │     ActiveUserModel stored in Riverpod
  │     UserManager.fetchUserProfile()    [Custom profile from backend]
  │     TokenManager.getToken()           [OAuth token fetched and cached]
  │     → DashboardPage
  │
  └── NO →
        → WelcomePage
              ↓
           [User taps Login]
              ↓
           catalystApp.login()            [Opens Zoho OAuth page]
              ↓
           LoadingPage (spinner)
              ↓
           AuthManager.fetchUser()
           UserManager.fetchUserProfile()
           TokenManager.getToken()
              ↓
           → DashboardPage
```

**Every API request** includes the header `Authorization: Zoho-oauthtoken <token>` — the token comes from `TokenManager.getToken()` which fetches it from Catalyst SDK.

**Role-based flow:**
- After login, `user.role.name` from `ZCatalystUser` determines what data is fetched and what UI is shown.
- Roles checked: `Admin`, `Admin (Default)`, `Super Admin`, `App Administrator`, `Manager/Team Lead`.
- Different API endpoints are called based on role (e.g., admin gets all tasks, user gets only their tasks).

**Logout:**
- `catalystApp.logout()` → clears Catalyst session.
- `TokenManager.clearToken()` → clears cached token.
- `UserManager.clear()` → clears cached profile.
- Navigate back to `WelcomePage`.

---

## 7. ALL API ENDPOINTS USED

Base URL (Development): `https://project-management-60040289923.development.catalystserverless.in/server/`
Base URL (Production): `https://project.dsv360.ai/server/`

All paths below are appended after the base URL.

| Method | Path | Used For |
|---|---|---|
| GET | `time_entry_management_application_function/mobile/dashboard?User_Id=&Org_Id=&Year=` | Dashboard stats (users, projects, tasks, issues counts + chart data) |
| GET | `time_entry_management_application_function/userprofile/{userId}` | Fetch logged-in user's custom profile (skills, bio, cover photo, etc.) |
| GET | `time_entry_management_application_function/tasks` | Fetch ALL tasks (Admin only) |
| GET | `time_entry_management_application_function/tasks/employee/{userId}` | Fetch tasks assigned to a specific user |
| POST | `time_entry_management_application_function/tasks/project` | Fetch tasks for a specific project (body: `{projectID}`) |
| POST | `time_entry_management_application_function/tasks` | Create a new task |
| PUT | `time_entry_management_application_function/tasks/{taskId}` | Update a task |
| GET | `time_entry_management_application_function/projects` | Fetch ALL projects (Admin only) |
| GET | `time_entry_management_application_function/projects/{userId}` | Fetch projects for a specific user |
| POST | `time_entry_management_application_function/projects` | Create a new project |
| PUT | `time_entry_management_application_function/projects/{projectId}` | Update a project |
| GET | `time_entry_management_application_function/issue` | Fetch ALL issues (Admin only) |
| GET | `time_entry_management_application_function/assignissue/{userId}` | Fetch issues assigned to a user |
| POST | `time_entry_management_application_function/issue` | Create a new issue |
| PUT | `time_entry_management_application_function/issue/{issueId}` | Update an issue |
| GET | `time_entry_management_application_function/employee` | Fetch all employees |
| GET | `time_entry_management_application_function/employees/{userId}` | Fetch pending tasks for a user |
| POST | `time_entry_management_application_function/batchProfile` | Fetch all users' batch profile data |
| GET | `time_entry_management_application_function/clientOrg` | Fetch all client organizations (accounts) |
| POST | `time_entry_management_application_function/clientOrg` | Create a new client org |
| PUT | `time_entry_management_application_function/clientOrg/{id}` | Update a client org |
| GET | `time_entry_management_application_function/contact` | Fetch all client contacts |
| POST | `time_entry_management_application_function/contact` | Create a new client contact |
| GET | `time_entry_management_application_function/feedback` | Fetch all feedbacks |
| POST | `time_entry_management_application_function/feedback` | Submit a new feedback |
| GET | `time_entry_management_application_function/leave/count?UserID=&Username=` | Fetch leave summary (paid/casual/sick counts) |
| GET | `time_entry_management_application_function/leave/approval` | Fetch all leave requests (Admin/Manager) |
| GET | `time_entry_management_application_function/leave/approval/{userId}` | Fetch leave requests for a specific user |
| POST | `time_entry_management_application_function/leave/approval/{rowId}` | Approve or reject a leave request |
| POST | `time_entry_management_application_function/leave` | Submit a new leave request |
| POST | `time_entry_management_application_function/attendance/dashboard?Start_date=&End_date=` | Fetch attendance / time logs for a date range (body: `{UserID}`) |
| POST | `time_entry_management_application_function/checkIn` | Check-in (sends device, lat, long, date, userId) |
| PUT | `time_entry_management_application_function/checkOut` | Check-out (sends device, lat, long, checkIn timestamp, rowId) |
| GET | `time_entry_management_application_function/status/{userId}` | Get user's current check-in status |
| GET | `time_entry_management_application_function/timeentry/timer?userId=` | Check timer running status for user |
| POST | `time_entry_management_application_function/timeentry/timer/start` | Start a task timer |
| POST | `time_entry_management_application_function/timeentry/timer/end` | Stop a running task timer |
| GET | `time_entry_management_application_function/timeentry?taskId=` | Get time entries by task |
| GET | `time_entry_management_application_function/timeentry/project/{projectId}` | Get time entries by project |
| POST | `time_entry_management_application_function/timeentry` | Create a manual time entry |
| PUT | `time_entry_management_application_function/timeentry/{id}` | Update a time entry |
| DELETE | `time_entry_management_application_function/timeentry/{id}` | Delete a time entry |
| POST | `ai_service/api/llm/answer` | Get AI LLM answer (text/code/vision model) |
| POST | `ai_service/api/rag/answer` | Get AI RAG answer (document-grounded bots) |

---

## 8. DATA FLOW — WHERE DATA COMES FROM AND WHERE IT SHOWS

### 8.1 User Data
```
Zoho Catalyst SDK (OAuth session)
  → AuthManager.fetchUser()
  → ZCatalystUser stored in AuthManager.instance.currentUser
  → Converted to ActiveUserModel → stored in Riverpod (activeUserRepositoryProvider)
  → Used in: DashboardTitle, ProfilePage, AppDrawer (name/email/avatar), IsHaveAccess (role checks)

Backend API: /userprofile/{userId}
  → UserManager.fetchUserProfile()
  → UserProfileModel stored in UserManager.instance.userProfile
  → Used in: ProfilePage (cover, skills, certifications), DashboardPage appbar (avatar)
```

### 8.2 Dashboard Data
```
Backend API: /mobile/dashboard?User_Id&Org_Id&Year
  → DashboardRepository.fetchDashboardData()
  → DashboardModel (userCnt, projectCnt, completedProjectCnt, issueCnt, taskCnt, yearTaskData, yearMonthwiseUserProjects)
  → dashboardDataProvider (Riverpod FutureProvider)
  → DashboardPage:
      StatGrid (shows userCnt, projectCnt, completedProjectCnt, issueCnt)
      TaskStatusCard (shows yearTaskData open/inProgress/closed as pie chart)
      ProjectAnalyticsCard (shows yearMonthwiseUserProjects as bar chart)
```

### 8.3 Projects Data
```
Backend API: /projects or /projects/{userId}
  → ProjectRepository.fetchProjects()
  → List<ProjectModel>
  → projectProvider (Riverpod)
  → ProjectsScreen: list of ProjectCard widgets
  → ProjectDetailsDialog: project info, tasks, time entries
```

### 8.4 Tasks Data
```
Backend API: /tasks or /tasks/employee/{userId} or /tasks/project (by role)
  → TasksListRepository (Riverpod @riverpod generator)
  → List<Task>
  → TasksScreen: list of task cards
  → TaskDetailsDialog: task info, timer, attachments
  
Pending Tasks:
Backend API: /employees/{userId}
  → PendingTasksListRepository
  → Shown in People Page → Overview tab
```

### 8.5 Issues Data
```
Backend API: /issue or /assignissue/{userId}
  → IssueRepository.fetchIssues()
  → List<IssueModel>
  → issueProvider (Riverpod)
  → IssuesScreen: list of issue cards
  → IssueDetailsModalSheet: full issue details
```

### 8.6 Attendance & Check-In Data
```
GPS (geolocator) → lat/long of device
Device name → sent as CIN_Device / COUT_Device
  → CheckInRepository.checkIn() / .checkOut()
  → Backend API: POST /checkIn, PUT /checkOut

Attendance history:
Backend API: POST /attendance/dashboard?Start_date=&End_date=
  → AttendanceDetailListRepository / AttendanceTrackerListRepository / TimeLogsRepository
  → List<AttendanceDetail>
  → People Page → Attendance tab / Time Logs tab / Attendance Tracker tab

Check-in Status:
Backend API: GET /status/{userId}
  → UserStatusRepository
  → UserCheckInStatus (isCheckedIn, rowId, checkInTime, etc.)
  → People Page → Overview tab (shows Check-In or Check-Out button)
```

### 8.7 Leave Data
```
Backend API: GET /leave/count
  → LeaveSummaryRepository
  → LeaveSummary (totalLeaves, usedLeaves, remainingLeaves by type)
  → People Page → Overview tab (leave summary cards)

Backend API: GET /leave/approval or /leave/approval/{userId}
  → LeaveDetailsListRepository
  → List<LeaveDetails>
  → People Page → Leaves tab / Leave Approval tab
  → LeaveDetailsPage: full leave detail + approve/reject actions

Backend API: POST /leave
  → Submit leave request from ApplyEditLeavePage
```

### 8.8 Holiday Data
```
Hardcoded in HolidayRepository (mock data, not from API)
  → List<Holiday> grouped by region (Mumbai, Pune, Vapi, Ambasamudram, etc.)
  → HolidayCalendarPage: calendar with marked holiday dates
```

### 8.9 Time Entry Data
```
Backend API: GET /timeentry?taskId= or GET /timeentry/project/{projectId}
  → TimeEntryRepository.getTimeEntriesByTask() / getTimeEntriesByProject()
  → List<TimeEntry>
  → TimeEntriesScreen: list of time entry cards, total hours

Timer:
GET /timeentry/timer?userId= → check timer status
POST /timeentry/timer/start → start timer
POST /timeentry/timer/end → stop timer
  → TaskDetailsDialog: timer UI with start/stop buttons
```

### 8.10 Users Data
```
Backend API: POST /batchProfile
  → UsersRepository.fetchUsersBatchProfile()
  → List<UsersModel>
  → UsersPage: list of all users with search
  → BadgesPage: users shown for badge assignment
```

### 8.11 Accounts / Client Org Data
```
Backend API: GET /clientOrg
  → AccountsListRepository + OrganizationRepository
  → List<Account> / List<Organization>
  → AccountsPage: list of client organizations
  → Project creation form: client dropdown populated from this data
```

### 8.12 Client Contacts Data
```
Backend API: GET /contact
  → ClientContactsRepository.fetchClientContactsList()
  → List<ClientContacts>
  → ClientContactsPage: list of client contacts
```

### 8.13 Feedback Data
```
Backend API: GET /feedback
  → FeedbackRepository.fetchFeedbacks()
  → List<FeedbackModel>
  → FeedbacksScreen: list of feedback cards, searchable
  → FeedbackDetailScreen: full content of one feedback
```

### 8.14 Badges Data
```
Hardcoded in AllDSVBadgesList (mock data — list of DSVBadge objects with URLs)
Badge tiers: Bronze, Silver, Gold, Platinum, Diamond, Titanium
  → BadgesPage: displayed alongside user list
  → AssignBadgesPage: select badge to assign to a user
```

### 8.15 AI Chat Data
```
User types a prompt in DsvAiPage
  → AiRepository.getLlmAnswer() → POST /ai_service/api/llm/answer
      (payload: prompt, model_type, model, images)
      (response: answer string)
  OR
  → AiRepository.getRagAnswer() → POST /ai_service/api/rag/answer
      (payload: query, documents)
      (response: answer string)
  → Response appended as ChatMessage to the in-memory _messages list
  → Displayed as chat bubble in DsvAiPage
```

### 8.16 Connectivity Status
```
Device network status (via connectivity_plus)
  → connectivityStatusProvider (Riverpod @riverpod Stream)
  → ConnectivityResult checked in:
      DashboardPage, TasksScreen, IssuesScreen, ProjectsScreen,
      UsersPage, BadgesPage, FeedbacksScreen, PeoplePage
  → If no connectivity: GlobalError widget shown with retry button instead of content
```

---

## 9. STATE MANAGEMENT — RIVERPOD USAGE

| Provider | Type | What it holds |
|---|---|---|
| `activeUserRepositoryProvider` | `NotifierProvider` | Logged-in user (ActiveUserModel) |
| `dashboardDataProvider` | `FutureProvider` | Dashboard stats from API |
| `dashboardRepositoryProvider` | `Provider` | DashboardRepository instance |
| `connectivityStatusProvider` | `StreamProvider` (@riverpod) | Real-time network status |
| `tasksListRepositoryProvider` | `AsyncNotifierProvider` (@riverpod) | List of tasks |
| `projectProvider` | `AsyncNotifierProvider` | List of projects |
| `issueProvider` | `AsyncNotifierProvider` | List of issues |
| `timeEntryProvider` | `AsyncNotifierProvider` | Time entries |
| `feedbackRepositoryProvider` | `AsyncNotifierProvider` | List of feedbacks |
| `feedbackSearchQueryProvider` | `StateProvider` | Feedback search query string |
| `usersRepositoryProvider` | `AsyncNotifierProvider` | List of users |
| `usersSearchQueryProvider` | `StateProvider` | Users search query string |
| `accountsListRepositoryProvider` | `AsyncNotifierProvider` | List of accounts |
| `accountsSearchQueryProvider` | `StateProvider` | Accounts search query |
| `clientContactsListRepositoryProvider` | `AsyncNotifierProvider` | List of client contacts |
| `clientContactsSearchQueryProvider` | `StateProvider` | Contacts search query |
| `organizationListRepositoryProvider` | `AsyncNotifierProvider` | List of organizations |
| `organizationSearchQueryProvider` | `StateProvider` | Org search query |
| `allDSVBadgesListRepositoryProvider` | `Provider` | Hardcoded list of badges |
| `pendingTasksListRepositoryProvider` | `AsyncNotifierProvider` (@riverpod) | Pending tasks for a user |
| `leaveSummaryRepositoryProvider` | `AsyncNotifierProvider` (@riverpod, keepAlive) | Leave summary counts |
| `leaveDetailsListRepositoryProvider` | `AsyncNotifierProvider` | Leave details list |
| `attendanceDetailListRepositoryProvider` | `AsyncNotifierProvider` (@riverpod) | Attendance detail list |
| `attendanceTrackerListRepositoryProvider` | `AsyncNotifierProvider` (@riverpod) | Attendance tracker (manager view) |
| `timeLogsRepositoryProvider` | `AsyncNotifierProvider` (@riverpod) | Time logs for date range |
| `checkInRepositoryProvider` | `AsyncNotifierProvider` (@riverpod) | Check-in/out operations |
| `userStatusRepositoryProvider` | `AsyncNotifierProvider` (autoDispose) | Current user check-in status |
| `aiRepositoryProvider` | `Provider` | AiRepository instance |
| `aiLoadingProvider` | `StateProvider` | AI page loading state |
| `aiModeProvider` | `StateProvider` | Selected AI mode (AI Model / RAG) |
| `aiModelProvider` | `StateProvider` | Selected AI model name |
| `aiImagesProvider` | `StateProvider` | Images selected for vision model |

---

## 10. ARCHITECTURE PATTERN

The app follows **MVVM + Repository Pattern**:

```
View (UI Widgets)
  ↕ watches/reads providers
Provider (Riverpod)
  ↕ calls repository
Repository (API calls, data parsing)
  ↕ calls
DioClient / http.Client
  ↕ HTTP request with Auth header
Catalyst Serverless Backend
```

Additionally:
- **Singleton managers** (`AppInitManager`, `AuthManager`, `TokenManager`, `UserManager`) handle cross-cutting concerns like auth and caching.
- **Models** are plain Dart classes with `fromJson()` factories for JSON parsing.
- **`@riverpod` annotation + build_runner** auto-generates provider boilerplate (`.g.dart` files).

---

## 11. NETWORKING (DioClient)

`DioClient` (`core/network/dio_client.dart`) is a **singleton** configured as:
- Base URL: from `ServerConstant.serverURL`.
- Connect timeout: 10 seconds.
- `followRedirects: false`.
- **Interceptor 1:** Before every request, calls `TokenManager.instance.getToken()` and injects `Authorization: Zoho-oauthtoken <token>` header automatically.
- **Interceptor 2:** `LogInterceptor` — logs every request URL, headers, body, and response body to the debug console.
- Supports: GET, POST, PUT (with proper error handling for each).
- Also has a second simpler `ApiClient` (`services/api_client.dart`) with base URL `https://api.dsv360.ai` but it is not the primary client used.

---

## 12. THEME SYSTEM

- `ThemeController` holds two `ValueNotifier`s: `themeMode` (light/dark) and `seedColor`.
- `buildLightTheme()` and `buildDarkTheme()` — build material themes with a `CustomColors` theme extension.
- `CustomColors` defines semantic color tokens: `primary`, `background`, `cardBackground`, `textPrimary`, `textSecondary`, `statusInProgress`, `statusCompleted`, `statusPending`, `success`, `error`, `tabbarBackground`, `chatBubbleBot`, etc.
- Accessed anywhere via `Theme.of(context).custom`.
- `SettingsPage` lets the user toggle dark/light — change is immediate app-wide.

---

## 13. ROLE-BASED ACCESS CONTROL SUMMARY

| Feature | Admin | Manager | Regular User |
|---|---|---|---|
| View all tasks | ✅ | ✅ (own projects) | ❌ (own only) |
| Create/edit tasks | ✅ | ✅ | ❌ |
| View all projects | ✅ | ❌ | ❌ (own only) |
| Create/edit projects | ✅ | ❌ | ❌ |
| View all issues | ✅ | ❌ | ❌ (assigned only) |
| Create issues | ✅ | ❌ | ❌ |
| Leave Approval tab | ✅ | ✅ | ❌ |
| Attendance Tracker tab | ❌ | ✅ | ❌ |
| People Page tabs | 4 | 6 | 4 |
| User management | ✅ | ❌ | ❌ |

---

## 14. ASSETS USED

Located in `assets/`:
- `assets/images/FI_logo.png` — main app logo shown on splash and welcome page.
- `assets/images/dsv.png` — DSV logo used in AppBar and Drawer.
- `assets/images/feedback.png` — placeholder image in attachment viewer.
- `assets/icons/` — icon assets (SVG/PNG).

---

## 15. KEY FILES QUICK REFERENCE

| File | Role |
|---|---|
| `lib/main.dart` | App entry point, SDK init, theme setup |
| `lib/core/constants/init_zcatalyst_app.dart` | Catalyst SDK singleton init |
| `lib/core/constants/auth_manager.dart` | Fetches & stores ZCatalystUser |
| `lib/core/constants/token_manager.dart` | Fetches & caches OAuth token |
| `lib/core/constants/user_manager.dart` | Fetches & caches custom user profile |
| `lib/core/constants/is_have_access.dart` | Role-based access helper (isAdmin, isManager) |
| `lib/core/constants/server_constant.dart` | Backend base URLs (dev/prod) |
| `lib/core/constants/environment.dart` | Environment switch (DEVELOPMENT/PRODUCTION) |
| `lib/core/network/dio_client.dart` | Singleton HTTP client with auth interceptor |
| `lib/core/constants/theme.dart` | ThemeController, custom colors, light/dark builders |
| `lib/repositories/` | All API call logic + Riverpod providers per feature |
| `lib/models/` | Plain Dart data models with fromJson() |
| `lib/providers/` | Cross-cutting Riverpod providers (dashboard, employee, etc.) |
| `lib/views/` | All UI screens and widgets, organized by feature |
| `lib/views/widgets/` | Reusable custom widgets |

---

## 16. WHAT IS NOT YET FULLY IMPLEMENTED

| Feature | Status |
|---|---|
| `routes.dart` (GoRouter setup) | Empty file — navigation done manually via `Navigator.push` |
| `lib/services/auth_service.dart` | Empty file (mock AuthService in `core/services/auth_service.dart` is not connected to real auth) |
| `lib/viewmodels/auth_viewmodel.dart` | Empty file |
| Teams Page | Only shows "Coming Soon" |
| Notifications | Hardcoded demo data, not real-time |
| Badges API | Hardcoded data, not connected to backend API |
| Holiday Calendar | Hardcoded data, not from API |
| `login_page.dart` (in views/auth/) | Empty file (login handled via WelcomePage + Catalyst SDK) |

---

## 17. ALL PLACES USING `package:http/http.dart` — TO BE MIGRATED TO DioClient

> These are every file and line that imports or uses `package:http/http.dart`. All of these need to be changed to use `DioClient` (which is the standard in this project and already handles auth token injection automatically).

---

### 17.1 `lib/repositories/dashboard_repository.dart`

| Line | Type | What it does |
|---|---|---|
| 3 | `import 'package:http/http.dart' as http;` | Import declaration |
| 26 | `await http.get(url, headers: {...})` | `GET /mobile/dashboard` — fetches dashboard stats |

**Total http calls: 1**

---

### 17.2 `lib/repositories/task_repository.dart`

| Line | Type | What it does |
|---|---|---|
| 10 | `import 'package:http/http.dart' as http;` | Import declaration |
| 55 | `await http.get(url, headers: {...})` | `GET /tasks` — fetch all tasks (Admin) |
| 70 | `await http.get(Uri.parse(projectsUrl))` | `GET /projects/{userId}` — fetch manager's projects to then get their tasks |
| 91 | `await http.post(Uri.parse(tasksUrl), ...)` | `POST /tasks/project` — fetch tasks for one project (Manager loop) |
| 120 | `await http.get(url, headers: {...})` | `GET /tasks/employee/{userId}` — fetch tasks for regular user |
| 141 | `_parseTasks(http.Response response)` | Helper method signature — takes `http.Response` as argument |
| 199 | `await http.get(Uri.parse(url))` | `GET /tasks/{taskId}` — fetch single task by ID |
| 226 | `await http.post(Uri.parse(url), ...)` | `POST /tasks` — create a new task (JSON body, no attachments) |
| 261 | `await http.get(uri)` | `GET /tasks` with query params — filter tasks |
| 376 | `await http.post(Uri.parse(url), ...)` | `POST /tasks` — create task (fallback or alternate path) |
| 433 | `http.MultipartRequest('POST', ...)` | `POST /tasks` — create task with file attachments (multipart) |
| 461 | `await http.MultipartFile.fromPath(...)` | Adds a file to the multipart form request |
| 474 | `await http.Response.fromStream(streamedResponse)` | Converts streamed multipart response to readable Response |
| 549 | `await http.post(Uri.parse(url), ...)` | `POST /tasks/{taskId}` — update a task |
| 578 | `await http.delete(Uri.parse(url))` | `DELETE /tasks/{taskId}` — delete a task |

**Total http calls: 11 (+ 3 multipart/response helper usages)**

---

### 17.3 `lib/repositories/project_repository.dart`

| Line | Type | What it does |
|---|---|---|
| 5 | `import 'package:http/http.dart' as http;` | Import declaration |
| 51 | `await http.get(Uri.parse(url), headers: {...})` | `GET /projects` or `GET /projects/{userId}` — fetch projects by role |
| 172 | `await http.post(Uri.parse(url), headers: {...}, body: ...)` | `POST /projects` — create a new project (JSON, no attachments) |
| 214 | `http.MultipartRequest('POST', ...)` | `POST /projects` — create project with file attachments (multipart) |
| 233 | `await http.MultipartFile.fromPath(...)` | Adds a file to the multipart create-project request |
| 245 | `await http.Response.fromStream(streamedResponse)` | Converts multipart create response to readable Response |
| 351 | `await http.post(Uri.parse(url), headers: {...}, body: ...)` | `POST /projects/{projectId}` — update project (JSON, no attachments) |
| 394 | `http.MultipartRequest('POST', ...)` | `POST /projects/{projectId}` — update project with file attachments (multipart) |
| 413 | `await http.MultipartFile.fromPath(...)` | Adds a file to the multipart update-project request |
| 425 | `await http.Response.fromStream(streamedResponse)` | Converts multipart update response to readable Response |
| 453 | `await http.delete(Uri.parse(url))` | `DELETE /delete/{projectId}` — delete a project |

**Total http calls: 4 (+ 6 multipart/response helper usages)**

---

### 17.4 `lib/repositories/issue_repository.dart`

| Line | Type | What it does |
|---|---|---|
| 4 | `import 'package:http/http.dart' as http;` | Import declaration |
| 38 | `await http.get(Uri.parse(url), headers: {...})` | `GET /issue` or `GET /assignissue/{userId}` — fetch issues by role |
| 104 | `await http.post(Uri.parse(url), headers: {...}, body: ...)` | `POST /issue` — create a new issue |
| 154 | `await http.post(Uri.parse(url), headers: {...}, body: ...)` | `POST /issue/{issueId}` — update an issue |
| 185 | `await http.delete(Uri.parse(url), headers: {...})` | `DELETE /issue/{issueId}` — delete an issue |

**Total http calls: 4**

---

### 17.5 `lib/repositories/employee_repository.dart`

| Line | Type | What it does |
|---|---|---|
| 4 | `import 'package:http/http.dart' as http;` | Import declaration |
| 27 | `await http.get(Uri.parse(url), headers: {...})` | `GET /employee` — fetch all employees (uses `Bearer` token — known issue) |
| 38 | `// final response = await http.get(...)` | **Commented-out** alternate call for same endpoint (uses `Zoho-oauthtoken`) |
| 92 | `await http.get(Uri.parse(url), headers: {...})` | `GET /employee` — second call path for fetching all employees |
| 133 | `await http.get(Uri.parse(url))` | `GET /emp/{userId}` — fetch a single employee by ID |

**Total http calls: 3 active (1 commented out)**

---

### 17.6 `lib/repositories/time_entry_repository.dart`

> This file uses `http.Client` (injected via constructor) instead of calling `http.get()` directly. The `httpClient` field is an instance of `http.Client`. All calls go through `httpClient.get/post/delete`.

| Line | Type | What it does |
|---|---|---|
| 3 | `import 'package:http/http.dart' as http;` | Import declaration |
| 9 | `final http.Client httpClient;` | Field declaration — holds the http.Client instance |
| 11–12 | `TimeEntryRepository({http.Client? httpClient})` | Constructor — accepts optional injected client, defaults to `http.Client()` |
| 21 | `await httpClient.get(...)` | `GET /timeentry/timer?userId=` — check if timer is running |
| 57 | `await httpClient.post(...)` | `POST /timeentry/timer/start` — start a task timer |
| 93 | `await httpClient.post(...)` | `POST /timeentry/timer/end` — stop a running timer |
| 127 | `await httpClient.get(...)` | `GET /timeentry/{taskId}` — fetch time entries by task |
| 197 | `await httpClient.get(...)` | `GET /time_entry/project/{projectId}?startDate=&endDate=` — filtered time entries by project |
| 243 | `await httpClient.get(...)` | `GET /time_entry/project/{projectId}` — all time entries by project |
| 298 | `await httpClient.get(...)` | `GET /time_entry/project/{projectId}` — get time entries by project (alternate) |
| 356 | `await httpClient.post(...)` | `POST /timeentry` — create a new manual time entry |
| 412 | `await httpClient.post(...)` | `POST /timeentry/{timeEntryId}` — update a time entry |
| 445 | `await httpClient.delete(...)` | `DELETE /timeentry/{timeEntryId}` — delete a time entry |
| 477 | `await httpClient.post(...)` | `POST /timeentry/approval/{userId}` — create approval request |
| 518 | `await httpClient.post(...)` | `POST /timeentry/approval` — approve or reject a time entry |
| 545 | `await httpClient.get(...)` | `GET /timeentry/approval/{userId}` — fetch user's pending approvals |
| 569 | `await httpClient.get(...)` | `GET /timeentry/approval?managerId=` — fetch team approvals (manager view) |

**Total http calls: 14**

---

### SUMMARY — All http Usage

| File | Import Line | Active http Calls | Notes |
|---|---|---|---|
| `lib/repositories/dashboard_repository.dart` | L3 | 1 | Simple GET, manually adds auth header |
| `lib/repositories/task_repository.dart` | L10 | 11 + 3 multipart | Manually adds auth header on most calls; multipart for file uploads |
| `lib/repositories/project_repository.dart` | L5 | 4 + 6 multipart | Manually adds auth header; multipart for file uploads |
| `lib/repositories/issue_repository.dart` | L4 | 4 | Manually adds auth header |
| `lib/repositories/employee_repository.dart` | L4 | 3 (1 commented) | Uses `Bearer` token instead of `Zoho-oauthtoken` on L27 — this is the known broken call |
| `lib/repositories/time_entry_repository.dart` | L3 | 14 | Uses `http.Client` via constructor injection |

**Grand Total: 37 active http calls across 6 files.**

> **Why migrate?** `DioClient` already injects the `Authorization: Zoho-oauthtoken <token>` header automatically via its interceptor, handles timeouts (10s), and logs all requests. Using raw `http` means you have to manually fetch and attach the token every time — and in some places (e.g., `employee_repository.dart` L27) the wrong token format is used (`Bearer` instead of `Zoho-oauthtoken`).


