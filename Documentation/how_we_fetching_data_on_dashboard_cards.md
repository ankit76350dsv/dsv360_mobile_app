# How Dashboard Card Data Is Fetched

> Documents the exact variable/field chain from Catalyst API → DashboardRepository → DashboardModel → Card widget.

---

## Task Status Card
**File:** `lib/views/dashboard/TaskStatusCard.dart`

### Step 1 · Year selection
- **Provider:** `selectedYearProvider` (`StateProvider<int>`) — `lib/providers/dashboard_provider.dart`
- User picks a year from `PopupMenuButton` in `TaskStatusCard`
- `onSelected`: `ref.read(selectedYearProvider.notifier).state = int.parse(v)`
- Default: `DateTime.now().year`

### Step 2 · Provider that drives the card
- **Provider:** `taskStatusDataProvider` (`FutureProvider<YearTaskData>`) — `lib/providers/dashboard_provider.dart`

```dart
final year = ref.watch(selectedYearProvider).toString()
// watching selectedYearProvider → card rebuilds on year change

final user = AuthManager.instance.currentUser
// user.id    → query param User_Id
// user.zaaid → query param Org_Id

final dash = await repository.fetchDashboardData(
  userId: user.id,
  orgId : user.zaaid,
  year  : year,
)
return dash.yearTaskData  // only this field is exposed to the card
```

### Step 3 · Repository / HTTP call
- **File:** `lib/repositories/dashboard_repository.dart` — class `DashboardRepository`

```dart
final _client = ApiClient.instance  // shared Dio singleton

// GET time_entry_management_application_function/mobile/dashboard
// Query params: ?User_Id=userId &Org_Id=orgId &Year=year

final response     = await _client.get(path, queryParameters: {...})
final jsonResponse = response.data  // Map<String, dynamic>

// Guard: jsonResponse['success'] == true
return DashboardModel.fromJson(jsonResponse)
```

### Step 4 · JSON → DashboardModel
- **File:** `lib/models/dashboard_model.dart` — class `DashboardModel`

| JSON key | Dart field |
|---|---|
| `jsonResponse['yearTaskData']` | `YearTaskData.fromJson()` |
| `jsonResponse['yearMonthwiseUserProjects']` | `List<YearMonthProjectData>` |
| `jsonResponse['userCnt']` | `userCnt` |
| `jsonResponse['taskCnt']` | `taskCnt` |
| `jsonResponse['projectCnt']` | `projectCnt` |
| `jsonResponse['completedProjectCnt']` | `completedProjectCnt` |
| `jsonResponse['issueCnt']` | `issueCnt` |

### Step 5 · JSON → YearTaskData
- **Class:** `YearTaskData`

| JSON key | Dart field | Type |
|---|---|---|
| `json['open']` | `open` | `int` |
| `json['in_progress']` | `inProgress` | `int` ← snake_case from backend |
| `json['closed']` | `closed` | `int` |

### Step 6 · Provider return value
- Returns `dash.yearTaskData` → `YearTaskData` object
- Only the task counts are exposed; the full `DashboardModel` is not passed to the card

### Step 7 · Card widget reads the provider
```dart
// TaskStatusCard.build()
final taskAsync = ref.watch(taskStatusDataProvider)
// → AsyncValue<YearTaskData>

taskAsync.when(
  data   : (taskData) => TaskStatusContent(taskData: taskData),
  loading: () => CircularLoader(),
  error  : (e, _)    => Text('Failed to load'),
)
```

### Step 8 · TaskStatusContent uses the data
```dart
// TaskStatusContent.build(taskData)
total         = taskData.open + taskData.inProgress + taskData.closed
openPct       = (taskData.open        / total) * 100
inProgressPct = (taskData.inProgress  / total) * 100
closedPct     = (taskData.closed      / total) * 100
```

**PieChart sections:**
| Section | Value | Color | Legend label |
|---|---|---|---|
| `sections[0]` | `closedPct` | `statusCompleted` | `Completed (${taskData.closed})` |
| `sections[1]` | `openPct` | `statusInProgress` | `Open (${taskData.open})` |
| `sections[2]` | `inProgressPct` | `error` | `In Progress (${taskData.inProgress})` |

---

## Project Analytics Card
**File:** `lib/views/dashboard/ProjectAnalyticsCard.dart`

### Step 1 · Year selection
- **Provider:** `selectedProjectYearProvider` (`StateProvider<int>`) — `lib/providers/dashboard_provider.dart`
- Separate from `selectedYearProvider` — the two cards are fully independent
- Default: `DateTime.now().year`

### Step 2 · Provider that drives the card
- **Provider:** `projectAnalyticsDataProvider` (`FutureProvider<List<YearMonthProjectData>>`) — `lib/providers/dashboard_provider.dart`

```dart
final year = ref.watch(selectedProjectYearProvider).toString()
final dash = await repository.fetchDashboardData(...)
return dash.yearMonthwiseUserProjects  // List of 12 monthly entries
```

### Step 3 · HTTP call
- Same `DashboardRepository.fetchDashboardData()`
- Same endpoint, same query params (`User_Id`, `Org_Id`, `Year`)

### Step 4 · JSON → List\<YearMonthProjectData\>
- Source: `jsonResponse['yearMonthwiseUserProjects']` (`List<dynamic>`)
- List index = month index (0 = Jan … 11 = Dec)

| JSON key | Dart field | Type |
|---|---|---|
| `e['open']` | `open` | `int` |
| `e['in_progress']` | `inProgress` | `int` |
| `e['closed']` | `closed` | `int` |

### Step 5 · Card widget reads the provider
```dart
// ProjectAnalyticsCard.build()
final analyticsAsync = ref.watch(projectAnalyticsDataProvider)
// → AsyncValue<List<YearMonthProjectData>>

analyticsAsync.when(
  data   : (monthData) => ListView(itemCount: monthData.length, ...),
  loading: () => CircularLoader(),
  error  : (e, _) => Text('Failed to load'),
)
```

### Step 6 · Per-month row uses the data
```dart
// _MonthAnalyticsRow(monthIndex: index, data: monthData[index])
data.open        → Open bar    (label 'Open')
data.inProgress  → Working bar (label 'Working')
data.closed      → Closed bar  (label 'Closed')

// Bar width formula:
barWidth = (value / 12) * 200.0
```
