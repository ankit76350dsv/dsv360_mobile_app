# Fix: In Progress Tasks Showing 0 in Pie Chart

## Root Cause

`YearTaskData.fromJson` in `lib/models/dashboard_model.dart` was reading:
```dart
inProgress: json['inProgress'] ?? 0,
```

The task status string stored in the database is `'In Progress'` (with a space). In the Node.js backend, this cannot be used as a variable name, so the developer maps it to `'in_progress'` (snake_case) in the JSON response. Dart's `?? 0` fallback silently returns 0 whenever the key is not found — so the chart always showed 0 for In Progress with no error.

`'open'` and `'closed'` worked because those are single lowercase words with no ambiguity.

---

## Changes Made

### Step 1 — Added import to `lib/models/dashboard_model.dart`

Added at the top of the file:
```dart
import 'package:flutter/foundation.dart';
```
Required for the `debugPrint` added in Step 2.

---

### Step 2 — Fixed `YearTaskData.fromJson` in `lib/models/dashboard_model.dart`

Changed from:
```dart
factory YearTaskData.fromJson(Map<String, dynamic> json) {
  return YearTaskData(
    open: json['open'] ?? 0,
    inProgress: json['inProgress'] ?? 0,
    closed: json['closed'] ?? 0,
  );
}
```

Changed to:
```dart
factory YearTaskData.fromJson(Map<String, dynamic> json) {
  debugPrint('📊 YearTaskData raw JSON: $json');
  return YearTaskData(
    open: json['open'] ?? 0,
    // Backend sends snake_case 'in_progress' for the 'In Progress' task status
    inProgress: json['in_progress'] ?? json['inProgress'] ?? 0,
    closed: json['closed'] ?? 0,
  );
}
```

`json['in_progress']` is tried first (the actual backend key), with `json['inProgress']` as fallback in case the backend is updated later to use camelCase.

The `debugPrint` logs the raw JSON so you can confirm the exact key the backend sends.

---

### Step 3 — Fixed `YearMonthProjectData.fromJson` in `lib/models/dashboard_model.dart`

Same fix applied to the second model class (used by the bar chart):

```dart
inProgress: json['in_progress'] ?? json['inProgress'] ?? 0,
```

---

### Step 4 — Added debug print to `lib/repositories/dashboard_repository.dart`

Added before `DashboardModel.fromJson` is called:
```dart
debugPrint('📋 yearTaskData raw from API: ${jsonResponse['yearTaskData']}');
```

This prints the raw `yearTaskData` object from the API response to the debug console so you can verify the exact key names being sent.

---

### Step 5 — Added debug print to `lib/views/dashboard/TaskStatusCard.dart`

Added after `total` is calculated:
```dart
debugPrint('📊 TaskStatusCard — open: ${taskData.open}, inProgress: ${taskData.inProgress}, closed: ${taskData.closed}, total: $total');
```

This confirms the widget is receiving the correct values after the model fix.

---

## Files Changed

| File | Change |
|------|--------|
| `lib/models/dashboard_model.dart` | Added import; fixed `inProgress` key in both `YearTaskData` and `YearMonthProjectData`; added debug print |
| `lib/repositories/dashboard_repository.dart` | Added debug print to log raw `yearTaskData` JSON |
| `lib/views/dashboard/TaskStatusCard.dart` | Added debug print to verify widget receives correct values |

---

## Cleanup (after confirming fix works)

Once you run the app and see the correct In Progress count in the chart, remove the three `debugPrint` lines added in Steps 2, 4, and 5.


## write you fix here
-
