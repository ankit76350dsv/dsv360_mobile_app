# Catalyst SDK — How It's Used in DSV360

---

## How Catalyst is Set Up

**Catalyst SDK** (`zcatalyst_sdk`) is the backbone for authentication and backend communication. It is initialized once when the app starts.

**Startup flow:**
1. `lib/main.dart` — calls `AppInitManager.instance.initCatalyst()` at boot
2. `lib/core/constants/init_zcatalyst_app.dart` — this is where `ZCatalystApp.init()` runs and the app instance is stored as a singleton

---

## What Catalyst Does in This App

Catalyst handles two things:

### 1. Auth (login / logout / current user)

| Where | What |
|---|---|
| `lib/views/welcome/welcome_page.dart` | `catalystApp.login()` — opens login screen |
| `lib/views/splash/splash_screen.dart` | `catalystApp.isUserLoggedIn()` — checks if user is already logged in |
| `lib/views/auth/loading_page.dart` | Fetches current user + token after login |
| `lib/views/profile/profile_page.dart` | `catalystApp.logout()` |
| `lib/views/dashboard/AppDrawer.dart` | `catalystApp.logout()` |
| `lib/core/constants/auth_manager.dart` | `app.getCurrentUser()` — gets logged-in user details |
| `lib/core/constants/token_manager.dart` | `app.getAccessToken()` — gets the Zoho OAuth token |

### 2. Every API Call (data fetch / write)

Catalyst doesn't store data in a local Datastore here — instead, all data lives in a **Catalyst Advanced I/O Function** (a serverless backend function called `time_entry_management_application_function`). Every API call needs the Catalyst token to be authorized.

The token flows like this:
```
TokenManager.getToken()
    → fetches from ZCatalystApp.getAccessToken()
    → DioClient / ApiClient interceptor auto-attaches it to every request
    → all repositories get authorized for free
```

---

## Pages and What Data They Fetch from Catalyst Backend

| Page | Data fetched / written |
|---|---|
| `lib/views/dashboard/dashboard_page.dart` | Reads dashboard summary (hours, projects, etc.) |
| `lib/views/projects/projects_screen.dart` | Reads all projects |
| `lib/views/projects/add_project_dialog.dart` | Reads projects + employees for the form |
| `lib/views/task/tasks_screen.dart` | Reads tasks |
| `lib/views/task/add_task_dialog.dart` | Reads projects + employees for the form |
| `lib/views/issues/issues_screen.dart` | Reads issues |
| `lib/views/issues/add_issue_form_screen.dart` | Writes new issue, reads projects + employees |
| `lib/views/time_entry/time_entries_screen.dart` | Reads / creates / updates / deletes time entries |
| `lib/views/time_entry/add_time_entry_dialog.dart` | Writes new time entry |

---

## Repositories and Their Catalyst Backend Operations

| Repository | File | Operations |
|---|---|---|
| `DashboardRepository` | `lib/repositories/dashboard_repository.dart` | READ dashboard summary |
| `EmployeeRepository` | `lib/repositories/employee_repository.dart` | READ all employees, READ by user ID |
| `ProjectRepository` | `lib/repositories/project_repository.dart` | READ all projects (admin), READ by user ID |
| `TaskRepository` | `lib/repositories/task_repository.dart` | READ tasks by employee, READ tasks by project, READ admin tasks |
| `IssueRepository` | `lib/repositories/issue_repository.dart` | READ issues, WRITE new issue |
| `TimeEntryRepository` | `lib/repositories/time_entry_repository.dart` | READ timer status, WRITE start/stop timer, CRUD time entries, WRITE create approval, WRITE respond to approval, READ approvals |

---

## Simple Mental Model

```
Catalyst SDK
    ├── Auth      → login, logout, getCurrentUser, isUserLoggedIn
    └── Token     → getAccessToken()
                        └── injected into every HTTP request (via DioClient / ApiClient)
                                └── hits Catalyst Functions backend
                                        ├── /projects
                                        ├── /tasks
                                        ├── /employee
                                        ├── /issues
                                        └── /time_entry (start, stop, CRUD, approvals)
```

So Catalyst is used for **auth** directly in views, and for **all data** indirectly through the token being attached to every API call automatically via `lib/core/network/dio_client.dart` and `lib/services/api_client.dart`.
