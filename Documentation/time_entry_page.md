# Time Entry Feature — Documentation

## Folder Structure

```
lib/features/time_entry/
├── model/
│   └── time_entry_model.dart
├── repositories/
│   └── time_entry_repository.dart
├── view/
│   └── pages/
│       ├── add_time_entry_dialog.dart
│       ├── running_timer_screen.dart
│       ├── time_entries_screen.dart
│       └── timer_service.dart
└── viewmodel/           ← EMPTY (not yet implemented)
```

---

## 1. Model — `time_entry_model.dart`

**What it is:** Data class representing a single time entry.

**Fields:**
| Field | Type | Source (API key) |
|---|---|---|
| `id` | String | `ROWID` or `id` |
| `user` | String | `Username` or `user` |
| `date` | DateTime | `Entry_Date` (format: `yyyy-MM-dd`) |
| `startTime` | String (HH:mm) | `Start_time` |
| `endTime` | String (HH:mm) | `End_time` |
| `type` | String | `Type` (`Billable` / `Non-Billable`) |
| `note` | String | `Note` or `note` |
| `createdAt` | DateTime | `CREATEDTIME` or `createdAt` |

**Methods:**

| Method | Used? | Purpose |
|---|---|---|
| `getDurationInHours()` | **NOT USED** anywhere in UI | Calculates hours between start/end. Could be used for reporting/display. |
| `toJson()` | **NOT USED** directly | Converts entry to JSON. Exists but repository builds its own body maps. |
| `fromJson()` | **USED** — in repository | Parses API response into `TimeEntry`. Handles both AM/PM and 24-hr time formats. Also handles the unusual `CREATEDTIME` format: `2026-02-05 17:28:58:810`. |

---

## 2. Repository — `time_entry_repository.dart`

**What it is:** All API calls for time entries. Uses `ApiClient.instance` (Dio singleton). Base URL + auth token are handled inside `ApiClient` — only relative paths are passed here.

---

### 2A. Timer Management APIs

#### `checkTimerStatus(userId)`
- **API:** `GET .../timeentry/timer?userId={userId}`
- **Returns:** `Map<String,dynamic>` — raw response (timer running state, timer ID, etc.)
- **Used by:** **NOT CALLED** anywhere in current UI — exists for future use
- **Why it exists:** To restore active timer state on app reopen

---

#### `startTimer({userId, taskId, projectId, description?})`
- **API:** `POST .../timeentry/timer/start`
- **Body:** `{ userId, taskId, projectId, description? }`
- **Returns:** `Map<String,dynamic>` — server-created timer record
- **Used by:** **NOT CALLED** anywhere in current UI
- **Why it exists:** Intended for server-tracked timers (vs. local `TimerService`). Currently the app uses local-only timer via `TimerService`.

---

#### `endTimer({userId, timerId})`
- **API:** `POST .../timeentry/timer/end`
- **Body:** `{ userId, timerId }`
- **Returns:** `Map<String,dynamic>`
- **Used by:** **NOT CALLED** anywhere in current UI
- **Note:** Has a bug — `debugPrint(body as String?)` will always throw since Map isn't a String

---

### 2B. Time Entry CRUD APIs

#### `getTimeEntriesByTask(taskId, {userId?})`
- **API:** `GET .../timeentry/{taskId}?userId={userId}`
- **Returns:** `List<TimeEntry>`
- **Response parsing:** Handles both flat array and nested structure (`data[i].details[j].Time_Entries`)
- **Used by:** **NOT USED** in current UI screens
- **Why it exists:** For task-level time entry view (not yet built)

---

#### `getTimeEntriesByProject(projectId)`
- **API:** `GET .../time_entry/project/{projectId}`
- **Returns:** `List<TimeEntry>`
- **Response parsing:** Nested — `data[i].details[j].Time_Entries`
- **Used by:**
  - `TimeEntriesScreen._fetchTimeEntries()` — on load and filter reset
  - `AddTimeEntryDialog._fetchExistingTimeEntries()` — to load entries for overlap check

---

#### `getTimeEntriesByProjectWithDateFilter({projectId, startDate?, endDate?})`
- **API:** `GET .../time_entry/project/{projectId}?startDate={}&endDate={}`
- **Returns:** `List<TimeEntry>`
- **Response parsing:** Same nested structure as above
- **Used by:** `TimeEntriesScreen._applyFilters()` — when user sets date range in filter sheet
- **Why separate from above:** Date filter is passed as query params to the API; avoids client-side date filtering on large datasets

---

#### `getTimeEntriesByUser({userId, startDate, endDate})`
- **API:** `GET .../user-timeentry?userId={}&startDate={}&endDate={}`
- **Returns:** `List<TimeEntry>`
- **Response parsing:** Flat array (no nested structure)
- **Used by:** **NOT USED** in current UI
- **Why it exists:** For user-level time report view (not yet built)

---

#### `createTimeEntry({taskId, projectId, userId, username, taskName, projectName, date, startTime, endTime, description?, totalMinutes?, type?})`
- **API:** `POST .../timeentry`
- **Body fields:** `Task_ID`, `Project_ID`, `User_ID`, `Username`, `Task_Name`, `Project_Name`, `Entry_Date`, `Start_time`, `End_time`, `Note?`, `Total_time?`, `Type?`
- **Returns:** `TimeEntry` — parses `response.data['data']`
- **Used by:**
  - `AddTimeEntryDialog._addTimeEntry()` — when user taps ADD (create mode)
  - `RunningTimerScreen._stopTimer()` — when user taps STOP TIMER

---

#### `updateTimeEntry({timeEntryId, taskId?, projectId?, userId?, date?, startTime?, endTime?, description?, totalMinutes?, type?})`
- **API:** `POST .../timeentry/{timeEntryId}` ← uses POST not PUT
- **Body fields:** Only non-null fields are sent (partial update)
- **Returns:** `TimeEntry`
- **Used by:** `AddTimeEntryDialog._addTimeEntry()` — when opened in edit mode (has `editingEntry`)

---

#### `deleteTimeEntry(timeEntryId)`
- **API:** `DELETE .../timeentry/{timeEntryId}`
- **Returns:** `bool` — `true` if `200` or `204`
- **Used by:** `TimeEntriesScreen._deleteTimeEntry()` — after user confirms delete dialog

---

### 2C. Approval APIs — ALL UNUSED

All 4 approval methods exist in the repository but are **not called anywhere in the current UI**. They are scaffolded for a future approval workflow.

| Method | API | Status |
|---|---|---|
| `createApprovalRequest({userId, startDate, endDate, timeEntryIds})` | `POST .../timeentry/approval/{userId}` | **NOT USED** |
| `respondToApproval({approvalId, status, comments?, reviewerId?})` | `POST .../timeentry/approval` | **NOT USED** |
| `getUserApprovals(userId)` | `GET .../timeentry/approval/{userId}` | **NOT USED** |
| `getTeamApprovals(managerId)` | `GET .../timeentry/approval?managerId={}` | **NOT USED** |

The "REQUEST" button in `AddTimeEntryDialog` currently shows a "Coming soon" snackbar and doesn't call any of these.

---

## 3. Views

### 3A. `AddTimeEntryDialog` — Create / Edit Time Entry

**Entry point:** Opened from task screen (create) or from `TimeEntriesScreen._editTimeEntry()` (edit).

**Props:**
- `taskId`, `projectId`, `taskName`, `projectName`, `currentUser` — required
- `editingEntry` — optional; if provided, widget runs in **edit mode**

**Flow — Create Mode:**
1. `initState` → sets default date to today, `_selectedType = 'Non-Billable'`
2. `initState` → calls `_fetchExistingTimeEntries()` to load project entries for overlap checking
3. User picks date (`_selectDate`), start time, end time (`_selectTime`), type, note
4. Taps ADD → `_addTimeEntry()`:
   - Validates start/end not empty
   - Validates end > start
   - Checks overlap via `_hasTimeOverlap()` against existing + locally added entries
   - Calls `repository.createTimeEntry(...)` → API
   - On success: adds to local `_timeEntries` list, clears form fields
5. Created entries shown in inline list; user can delete them locally via `_deleteTimeEntry(index)`
6. Timer button: if `TimerService.isRunning` → navigates to `RunningTimerScreen`; else starts local timer

**Flow — Edit Mode:**
1. `initState` → pre-populates all fields from `editingEntry`
2. User edits fields → taps SAVE → `_addTimeEntry()`:
   - Same validation + overlap check (excludes self via `excludeEntryId`)
   - Calls `repository.updateTimeEntry(...)` → API
   - On success: pops with updated `TimeEntry` result

**Unused / Dead Code:**
- `_submitTimeEntries()` — fully commented out. Was the old batch-submit flow (submit all entries at once). Replaced by per-entry immediate `createTimeEntry` calls.
- `_deleteTimeEntry(index)` — only removes from local `_timeEntries` list in memory. Does **not** call `repository.deleteTimeEntry`. Real delete is only in `TimeEntriesScreen`.

---

### 3B. `RunningTimerScreen` — Stop Active Timer & Save Entry

**Entry point:** Navigated to from `AddTimeEntryDialog` when timer is running.

**Props:** `taskId`, `projectId`, `taskName`, `projectName`

**Flow:**
1. `initState` → attaches `_onTick` listener to `TimerService` (rebuilds UI every second)
2. UI shows: read-only user, read-only today's date, read-only start time (from `TimerService.startTimeFormatted`), live end time (from `TimerService.currentClockTime`)
3. User picks type, adds note
4. Taps STOP TIMER → `_stopTimer()`:
   - Reads `timer.startTimeFormatted` as start time
   - Calculates current time as end time
   - Calls `repository.createTimeEntry(...)` → API
   - On success: calls `timer.stop()` (resets `TimerService`), pops with `true`
   - On error: shows "Please wait at least 1 minute then try again" — backend rejects < 1 min entries

**Important:** The local `TimerService` is completely separate from the repository's `startTimer`/`endTimer` APIs. The app does **not** persist timer state to the server — if the app is killed, the timer is lost.

---

### 3C. `TimeEntriesScreen` — View, Filter, Edit, Delete Entries

**Entry point:** From `AddTimeEntryDialog` timer icon / "View All" snackbar action.

**Props:** `taskId`, `projectId`, `taskName`, `projectName`, `timeEntries` (initial list, default empty)

**Flow — Load:**
1. `initState` → calls `_fetchTimeEntries()` → `repository.getTimeEntriesByProject(projectId)`
2. Sets `_allEntries` and `displayedEntries` from response

**Flow — Filter:**
1. User taps Filters → `_showFilterDialog()` → opens `_FilterBottomSheet`
2. User selects From date, To date, Entry Type → taps Apply
3. `_applyFilters()`:
   - If any date set → calls `repository.getTimeEntriesByProjectWithDateFilter(...)` → updates `_allEntries`
   - Then filters `displayedEntries` client-side by `_billableFilter`
4. Filter chip shows count of active filters; `onDeleted` → `_clearFilters()` → re-fetches all

**Flow — Edit:**
1. `_editTimeEntry(entry)` → opens `AddTimeEntryDialog` in edit mode as a dialog (not full screen route)
2. On dialog result: updates entry in `_allEntries` list, re-applies current filters

**Flow — Delete:**
1. `_deleteTimeEntry(entry)` → confirmation `AlertDialog`
2. On confirm: `repository.deleteTimeEntry(entry.id)` → removes from `_allEntries` → re-applies filters

---

### 3D. `TimerService` — Local In-Memory Timer

**What it is:** Singleton `ChangeNotifier`. Manages a local stopwatch — no API calls.

**Access:** `TimerService.instance` (anywhere in app)

**Getters:**

| Getter | Returns | Used By |
|---|---|---|
| `isRunning` | bool | `AddTimeEntryDialog` (timer button state) |
| `startTime` | `DateTime?` | Internal only |
| `elapsed` | `Duration` | Used internally for `elapsedFormatted` |
| `elapsedFormatted` | `"HH:MM:SS"` | `AddTimeEntryDialog` (timer button label) |
| `startTimeFormatted` | `"h:mm AM/PM"` | `RunningTimerScreen` (start time display + passed to createTimeEntry) |
| `currentClockTime` | `"h:mm:ss AM/PM"` | `RunningTimerScreen` (live end time display) |

**Methods:**

| Method | What it does | Used By |
|---|---|---|
| `start()` | Records `_startTime = now`, starts 1-second `Timer.periodic`, calls `notifyListeners` | `AddTimeEntryDialog` (play button) |
| `stop()` | Cancels ticker, resets `_startTime` and `_isRunning` to null/false | `RunningTimerScreen._stopTimer()` after createTimeEntry succeeds |

---

## 4. Complete Flow Diagrams

### Flow 1 — Manual Time Entry (Create)

```
User opens task → AddTimeEntryDialog
  ↓
initState:
  - _fetchExistingTimeEntries() → GET /time_entry/project/{projectId}
  
User fills form → taps ADD
  ↓
_addTimeEntry():
  - Validate times
  - _hasTimeOverlap() → checks against _existingEntries + _timeEntries
  - repository.createTimeEntry() → POST /timeentry
  - Add result to _timeEntries (shown inline)
```

### Flow 2 — Timer-based Entry

```
User taps Play in AddTimeEntryDialog
  ↓
TimerService.instance.start()   ← local only, no API
  - Button shows elapsed time + turns red

User taps Stop button → RunningTimerScreen
  ↓
_stopTimer():
  - Get startTime from TimerService.startTimeFormatted
  - Get endTime from current DateTime
  - repository.createTimeEntry() → POST /timeentry
  - TimerService.instance.stop()   ← resets local timer
  - Pop back
```

### Flow 3 — View & Filter Entries

```
User navigates to TimeEntriesScreen
  ↓
_fetchTimeEntries() → GET /time_entry/project/{projectId}
  ↓
User taps Filters → _FilterBottomSheet
  - Selects date range and/or type
  - Taps Apply
  ↓
_applyFilters():
  - If dates set → GET /time_entry/project/{projectId}?startDate=&endDate=
  - Then filter displayedEntries by type (client-side)
```

### Flow 4 — Edit Entry

```
TimeEntriesScreen._editTimeEntry(entry)
  ↓
AddTimeEntryDialog(editingEntry: entry)   ← opens as dialog
  ↓
User changes fields → taps SAVE
  ↓
repository.updateTimeEntry(timeEntryId, ...) → POST /timeentry/{id}
  ↓
Dialog pops with updatedEntry
  ↓
TimeEntriesScreen updates _allEntries[index] + re-filters
```

### Flow 5 — Delete Entry

```
TimeEntriesScreen._deleteTimeEntry(entry)
  ↓
AlertDialog confirmation
  ↓
repository.deleteTimeEntry(entry.id) → DELETE /timeentry/{id}
  ↓
_allEntries.removeWhere(id == entry.id)
_applyFilters() → refresh displayedEntries
```

---

## 5. What's Not Yet Implemented

| Feature | Code Exists? | Status |
|---|---|---|
| Server-side timer (`startTimer` / `endTimer` / `checkTimerStatus`) | Yes — repository methods ready | NOT connected to UI |
| Timer persistence across app restarts | No | Local `TimerService` resets on kill |
| Approval workflow (create, respond, view approvals) | Yes — all 4 repo methods ready | NOT connected to UI; "REQUEST" button shows "Coming soon" |
| MVVM ViewModel layer | No — `viewmodel/` folder is empty | All logic lives directly in view widgets |
| User-level time report (`getTimeEntriesByUser`) | Yes — repo method ready | NOT used in any screen |
| Task-level time entries (`getTimeEntriesByTask`) | Yes — repo method ready | NOT used in any screen |
| `TimeEntry.getDurationInHours()` | Yes — model method | NOT called anywhere |
| `TimeEntry.toJson()` | Yes — model method | NOT called anywhere |
| Batch submit (`_submitTimeEntries`) | Yes — fully coded but commented out | Replaced by per-entry immediate creation |
