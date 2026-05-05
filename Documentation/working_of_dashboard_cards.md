# How Year Filtering Works in Task Status Card

## Files Involved

| File | Role |
|------|------|
| `lib/providers/dashboard_provider.dart` | Holds the selected year state + fetches dashboard data |
| `lib/repositories/dashboard_repository.dart` | Sends the API call with the year as a query param |
| `lib/views/dashboard/TaskStatusCard.dart` | Shows the year picker button to the user |
| `lib/views/dashboard/dashboard_page.dart` | Renders `TaskStatusCard` with the data from the provider |
| `lib/models/dashboard_model.dart` | Parses the API JSON response into `YearTaskData` |

---

## Step-by-Step Flow

### Step 1 — App starts, default year is set
- **File:** `dashboard_provider.dart`
- `selectedYearProvider` is a `StateProvider<int>`.
- It defaults to `DateTime.now().year` (e.g. `2026`).
- No user action needed — this runs automatically on app start.

---

### Step 2 — `dashboardDataProvider` watches the selected year
- **File:** `dashboard_provider.dart`
- `dashboardDataProvider` is a `FutureProvider<DashboardModel>`.
- Inside it, it calls `ref.watch(selectedYearProvider)`.
- This means: **whenever the year changes, this provider re-runs automatically.**

---

### Step 3 — `dashboardDataProvider` calls the repository with the year
- **File:** `dashboard_provider.dart` → calls `dashboard_repository.dart`
- The year integer is converted to a string: `.toString()`.
- It is passed as the `year` argument to `fetchDashboardData(userId, orgId, year)`.

---

### Step 4 — Repository sends year as a query parameter to the API
- **File:** `dashboard_repository.dart`
- Makes a GET request to:
  `time_entry_management_application_function/mobile/dashboard`
- Query parameters sent:
  ```
  User_Id=<userId>
  Org_Id=<orgId>
  Year=<selectedYear>   ← this is the year filter
  ```
- The backend uses the `Year` param to filter task data for that year only.

---

### Step 5 — API response is parsed into `YearTaskData`
- **File:** `dashboard_model.dart`
- The API returns JSON with a `yearTaskData` key.
- `YearTaskData.fromJson` reads three keys from it:
  - `open` → count of open tasks
  - `in_progress` → count of in-progress tasks
  - `closed` → count of closed/completed tasks
- These counts are **already filtered by year** — the backend did the filtering in Step 4.

---

### Step 6 — `dashboard_page.dart` passes `yearTaskData` to `TaskStatusCard`
- **File:** `dashboard_page.dart`
- The page watches `dashboardDataProvider`.
- When data arrives, it passes `dashboard.yearTaskData` to `TaskStatusCard`:
  ```dart
  TaskStatusCard(taskData: dashboard.yearTaskData)
  ```

---

### Step 7 — `TaskStatusCard` shows the year picker button
- **File:** `TaskStatusCard.dart`
- `TaskStatusCard` is a `ConsumerWidget` (not `StatelessWidget`), so it can access Riverpod providers.
- It reads the current selected year with `ref.watch(selectedYearProvider)`.
- The `trailing` of the `ListTile` is a `PopupMenuButton<int>` that shows the selected year and a dropdown arrow.
- The year list is built as: current year and 4 years before it (e.g. 2026, 2025, 2024, 2023, 2022).

---

### Step 8 — User taps the year button and picks a year
- **File:** `TaskStatusCard.dart`
- The `PopupMenuButton.onSelected` callback fires.
- It writes the new year into the provider:
  ```dart
  ref.read(selectedYearProvider.notifier).state = year;
  ```

---

### Step 9 — Everything re-runs automatically
- Because `dashboardDataProvider` is watching `selectedYearProvider` (Step 2), it **automatically invalidates and re-runs**.
- It calls the API again — this time with the new year in the `Year` query param (Step 4).
- The new `YearTaskData` (open/inProgress/closed counts for the chosen year) is parsed (Step 5).
- `dashboard_page.dart` rebuilds with the new data (Step 6).
- The pie chart and legend in `TaskStatusContent` update to show the correct numbers for the chosen year.

---

## Summary Diagram

```
User taps year "2025"
        ↓
selectedYearProvider.state = 2025          (TaskStatusCard.dart)
        ↓
dashboardDataProvider re-runs              (dashboard_provider.dart)
  because it watches selectedYearProvider
        ↓
API called with &Year=2025                 (dashboard_repository.dart)
        ↓
Backend returns task counts for 2025
        ↓
YearTaskData.fromJson parses open/         (dashboard_model.dart)
  in_progress/closed
        ↓
TaskStatusCard pie chart updates           (TaskStatusCard.dart)
  to show 2025 data
```

---

## Project Data Model — `YearMonthProjectData`

### Where it lives
- **File:** `lib/models/dashboard_model.dart`
- Class name: `YearMonthProjectData`

### What it holds
Each object represents one month's project task counts:
- `open` — number of open projects/tasks
- `inProgress` — number of in-progress projects/tasks
- `closed` — number of closed/completed projects/tasks

### How it is parsed
- The API returns a JSON key `yearMonthwiseUserProjects` which is a **list** (one item per month).
- In `DashboardModel.fromJson`, that list is mapped to `List<YearMonthProjectData>`:
  ```dart
  yearMonthwiseUserProjects: (json['yearMonthwiseUserProjects'] as List<dynamic>?)
      ?.map((e) => YearMonthProjectData.fromJson(e))
      .toList() ?? []
  ```
- `YearMonthProjectData.fromJson` reads `open`, `in_progress`, and `closed` from each item.

### How it reaches the UI
- **File:** `lib/views/dashboard/dashboard_page.dart`
- `dashboard_page.dart` passes the full list to `ProjectAnalyticsCard`:
  ```dart
  ProjectAnalyticsCard(monthData: dashboard.yearMonthwiseUserProjects)
  ```
- **File:** `lib/views/dashboard/ProjectAnalyticsCard.dart`
- `ProjectAnalyticsCard` receives `List<YearMonthProjectData> monthData` and uses it to render the bar/analytics chart, one entry per month.
