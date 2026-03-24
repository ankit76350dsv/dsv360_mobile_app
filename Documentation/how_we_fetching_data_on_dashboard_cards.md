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

---

## Complete Data Flow — Task Status Card (open / inProgress / closed)

> Start: Zoho Catalyst server → End: numbers shown in the pie chart on the dashboard

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SOURCE  ·  Zoho Catalyst Serverless API                                    │
│                                                                             │
│  URL (prod) : https://project.dsv360.ai/server/                             │
│               time_entry_management_application_function/mobile/dashboard   │
│  URL (dev)  : https://project-management-...development.catalystserverless  │
│               .in/server/time_entry_management_application_function/        │
│               mobile/dashboard                                              │
│                                                                             │
│  File       : lib/core/constants/server_constant.dart                       │
│  Class      : ServerConstant                                                │
│  Variable   : ServerConstant.serverURL                                      │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  HTTP GET  + query params
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 1  ·  HTTP Client                                                    │
│                                                                             │
│  File    : lib/core/network/dio_client.dart                                 │
│  Class   : ApiClient  (singleton)                                           │
│  Access  : ApiClient.instance                                               │
│  Field   : _dio  (Dio)  — baseUrl = ServerConstant.serverURL                │
│                                                                             │
│  Auth interceptor reads:                                                    │
│    token ← TokenManager.instance.getToken()                                 │
│    header: 'Authorization': 'Zoho-oauthtoken $token'                        │
│                                                                             │
│  Method called:                                                             │
│    _client.get(path, queryParameters: {                                     │
│      'User_Id' : userId,                                                    │
│      'Org_Id'  : orgId,                                                     │
│      'Year'    : year,                                                      │
│    })                                                                       │
│                                                                             │
│  Returns: Response  (Dio)                                                   │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  Response.data  →  Map<String, dynamic>
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 2  ·  User Identity (query param source)                             │
│                                                                             │
│  File    : lib/core/constants/auth_manager.dart                             │
│  Class   : AuthManager  (singleton)                                         │
│  Access  : AuthManager.instance                                             │
│  Field   : currentUser  (ZCatalystUser?)                                    │
│                                                                             │
│  Values read from currentUser:                                              │
│    currentUser.id     → passed as  User_Id  query param                     │
│    currentUser.zaaid  → passed as  Org_Id   query param                     │
│                                                                             │
│  ZCatalystUser is a model from the zcatalyst_sdk package                    │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  userId, orgId, year
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 3  ·  Repository                                                     │
│                                                                             │
│  File    : lib/repositories/dashboard_repository.dart                       │
│  Class   : DashboardRepository                                              │
│  Field   : _client = ApiClient.instance                                     │
│                                                                             │
│  Method  : fetchDashboardData({userId, orgId, year})                        │
│    1. calls _client.get(path, queryParameters)                              │
│    2. stores result in:  final response = await _client.get(...)            │
│    3. extracts body  :   final jsonResponse = response.data                 │
│                          // Map<String, dynamic>                            │
│    4. checks guard  :    jsonResponse['success'] == true                    │
│    5. parses        :    return DashboardModel.fromJson(jsonResponse)        │
│                                                                             │
│  Raw JSON keys available in jsonResponse:                                   │
│    jsonResponse['success']                    → bool                        │
│    jsonResponse['userCnt']                    → int                         │
│    jsonResponse['taskCnt']                    → int                         │
│    jsonResponse['projectCnt']                 → int                         │
│    jsonResponse['completedProjectCnt']        → int                         │
│    jsonResponse['issueCnt']                   → int                         │
│    jsonResponse['yearTaskData']               → Map  ← WE WANT THIS         │
│    jsonResponse['yearMonthwiseUserProjects']  → List                        │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  jsonResponse  →  DashboardModel.fromJson()
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 4  ·  Model — DashboardModel                                         │
│                                                                             │
│  File    : lib/models/dashboard_model.dart                                  │
│  Class   : DashboardModel                                                   │
│                                                                             │
│  DashboardModel.fromJson(jsonResponse):                                     │
│    field: yearTaskData  ← YearTaskData.fromJson(                            │
│                               jsonResponse['yearTaskData']                  │
│                             )                                               │
│                                                                             │
│  (other fields are irrelevant for the Task Status card)                     │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  jsonResponse['yearTaskData']  →  YearTaskData.fromJson()
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 5  ·  Model — YearTaskData                                           │
│                                                                             │
│  File    : lib/models/dashboard_model.dart                                  │
│  Class   : YearTaskData                                                     │
│                                                                             │
│  YearTaskData.fromJson(json):                                               │
│    json['open']        → field: open        (int)  ← Open tasks             │
│    json['in_progress'] → field: inProgress  (int)  ← In Progress tasks      │
│    json['closed']      → field: closed      (int)  ← Completed tasks        │
│                                                                             │
│  NOTE: backend sends snake_case 'in_progress',                              │
│        Dart model stores it in camelCase 'inProgress'                       │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  returns DashboardModel  (contains .yearTaskData)
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 6  ·  Year State                                                     │
│                                                                             │
│  File     : lib/providers/dashboard_provider.dart                           │
│  Provider : selectedYearProvider  (StateProvider<int>)                      │
│  Default  : DateTime.now().year                                             │
│                                                                             │
│  Changed by user via PopupMenuButton in TaskStatusCard:                     │
│    onSelected: (v) =>                                                       │
│      ref.read(selectedYearProvider.notifier).state = int.parse(v)           │
│                                                                             │
│  When this changes → taskStatusDataProvider is invalidated → re-fetches    │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  year (String)  passed into fetchDashboardData
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 7  ·  Riverpod Provider                                              │
│                                                                             │
│  File     : lib/providers/dashboard_provider.dart                           │
│  Provider : taskStatusDataProvider  (FutureProvider<YearTaskData>)          │
│                                                                             │
│  Inside the provider:                                                       │
│    final repository = ref.watch(dashboardRepositoryProvider)                │
│    final user       = AuthManager.instance.currentUser                      │
│    final year       = ref.watch(selectedYearProvider).toString()            │
│                                                                             │
│    final dash = await repository.fetchDashboardData(                        │
│      userId : user.id,                                                      │
│      orgId  : user.zaaid,                                                   │
│      year   : year,                                                         │
│    )                                                                        │
│    return dash.yearTaskData    ←  YearTaskData object                       │
│                                                                             │
│  Exposed type: AsyncValue<YearTaskData>                                     │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  AsyncValue<YearTaskData>
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 8  ·  Widget — TaskStatusCard                                        │
│                                                                             │
│  File    : lib/views/dashboard/TaskStatusCard.dart                          │
│  Class   : TaskStatusCard  (ConsumerWidget)                                 │
│                                                                             │
│  final taskAsync = ref.watch(taskStatusDataProvider)                        │
│    → AsyncValue<YearTaskData>                                               │
│                                                                             │
│  taskAsync.when(                                                            │
│    loading: () → shows CircularLoader()                                     │
│    error  : (e, _) → shows Text('Failed to load')                          │
│    data   : (taskData) → passes to TaskStatusContent(taskData: taskData)    │
│  )                                                                          │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  taskData  (YearTaskData)
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 9  ·  Widget — TaskStatusContent                                     │
│                                                                             │
│  File    : lib/views/dashboard/TaskStatusCard.dart                          │
│  Class   : TaskStatusContent  (StatelessWidget)                             │
│  Param   : taskData  (YearTaskData)                                         │
│                                                                             │
│  Calculations:                                                              │
│    total         = taskData.open + taskData.inProgress + taskData.closed    │
│    closedPct     = (taskData.closed      / total) * 100                     │
│    openPct       = (taskData.open        / total) * 100                     │
│    inProgressPct = (taskData.inProgress  / total) * 100                     │
│                                                                             │
│  PieChart sections (fl_chart):                                              │
│    sections[0]  value=closedPct      color=statusCompleted  (green)         │
│    sections[1]  value=openPct        color=statusInProgress (blue)          │
│    sections[2]  value=inProgressPct  color=error            (red)           │
│                                                                             │
│  Legend labels:                                                             │
│    • "Completed   (taskData.closed)"                                        │
│    • "Open        (taskData.open)"                                          │
│    • "In Progress (taskData.inProgress)"                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Files involved — quick reference

| Layer | File | Key identifier |
|---|---|---|
| Base URL | `lib/core/constants/server_constant.dart` | `ServerConstant.serverURL` |
| HTTP client | `lib/core/network/dio_client.dart` | `ApiClient.instance` → `_dio.get()` |
| Auth / user | `lib/core/constants/auth_manager.dart` | `AuthManager.instance.currentUser` → `.id`, `.zaaid` |
| Repository | `lib/repositories/dashboard_repository.dart` | `DashboardRepository.fetchDashboardData()` → `response.data` → `jsonResponse` |
| Full model | `lib/models/dashboard_model.dart` | `DashboardModel` → `.yearTaskData` |
| Task model | `lib/models/dashboard_model.dart` | `YearTaskData` → `.open` `.inProgress` `.closed` |
| Year state | `lib/providers/dashboard_provider.dart` | `selectedYearProvider` |
| Data provider | `lib/providers/dashboard_provider.dart` | `taskStatusDataProvider` → returns `YearTaskData` |
| Card shell | `lib/views/dashboard/TaskStatusCard.dart` | `TaskStatusCard` → `ref.watch(taskStatusDataProvider)` |
| Chart + legend | `lib/views/dashboard/TaskStatusCard.dart` | `TaskStatusContent(taskData:)` → `taskData.open / .inProgress / .closed` |
