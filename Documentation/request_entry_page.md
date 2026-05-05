# Request Time Entries Screen - Setup Guide

## Goal
Add multiple time entries as JSON string, save them to a variable, and send to server.

---

## Step 1: Update TimeEntry Model

**File:** `lib/features/time_entry/model/time_entry_model.dart`

**Update your TimeEntry class to match API format:**

```dart
class TimeEntry {
  final String id;
  final String username;
  final String userId;
  final String entryDate;
  final String note;
  final String type;
  final String startTime;
  final String endTime;
  final int totalTime;
  final String taskId;
  final String taskName;
  final String projectId;
  final String projectName;

  TimeEntry({
    required this.id,
    required this.username,
    required this.userId,
    required this.entryDate,
    required this.note,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.totalTime,
    required this.taskId,
    required this.taskName,
    required this.projectId,
    required this.projectName,
  });

  // Convert to JSON Map (for API request)
  Map<String, dynamic> toJson() {
    return {
      'Username': username,
      'User_ID': userId,
      'Entry_Date': entryDate,
      'Note': note,
      'Type': type,
      'Start_time': startTime,
      'End_time': endTime,
      'Total_time': totalTime,
      'Task_ID': taskId,
      'Task_Name': taskName,
      'Project_ID': projectId,
      'Project_Name': projectName,
    };
  }
}
```

---

## Step 1.5: Add Time Calculation Function

**In `_RequestTimeEntriesScreenState` class, add this function:**

```dart
int _calculateTotalMinutes(String startTimeAMPM, String endTimeAMPM) {
  try {
    final format = DateFormat('h:mm a');
    final startTime = format.parse(startTimeAMPM);
    final endTime = format.parse(endTimeAMPM);
    
    Duration duration = endTime.difference(startTime);
    if (duration.isNegative) {
      duration = Duration(hours: 24) + duration;
    }
    return duration.inMinutes;
  } catch (e) {
    debugPrint('Error calculating total minutes: $e');
    return 0;
  }
}
```

---

## Step 2: Add Required Fields to State

**File:** `lib/features/time_entry/view/pages/request_time_entries_screen.dart`

**In `_RequestTimeEntriesScreenState` class, add these variables after existing ones:**

```dart
late TextEditingController _taskIdController;
late TextEditingController _taskNameController;
late TextEditingController _projectIdController;
late TextEditingController _projectNameController;

String? _userId;
```

---

## Step 3: Initialize Controllers in initState()

**In `initState()` method, add these lines with other controllers:**

```dart
_taskIdController = TextEditingController();
_taskNameController = TextEditingController();
_projectIdController = TextEditingController();
_projectNameController = TextEditingController();

// Get userId from AuthManager
_userId = AuthManager.instance.currentUser?.id ?? '';
```

---

## Step 4: Initialize Entries List

**In `_RequestTimeEntriesScreenState` class, add:**

```dart
final List<TimeEntry> _entries = [];
```

---

## Step 5: Update _addTimeEntry() Function

**Replace the entire `_addTimeEntry()` function with this:**

```dart
void _addTimeEntry() {
  if (_selectedDate == null ||
      _startTimeController.text.isEmpty ||
      _endTimeController.text.isEmpty ||
      _selectedType == null ||
      _taskIdController.text.isEmpty ||
      _taskNameController.text.isEmpty ||
      _projectIdController.text.isEmpty ||
      _projectNameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all required fields")),
    );
    return;
  }

  final totalMinutes = _calculateTotalMinutes(
    _startTimeController.text,
    _endTimeController.text,
  );

  final newEntry = TimeEntry(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    username: _userController.text,
    userId: _userId ?? '',
    entryDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
    note: _noteController.text,
    type: _selectedType!,
    startTime: _startTimeController.text,
    endTime: _endTimeController.text,
    totalTime: totalMinutes,
    taskId: _taskIdController.text,
    taskName: _taskNameController.text,
    projectId: _projectIdController.text,
    projectName: _projectNameController.text,
  );

  setState(() {
    _entries.add(newEntry);

    // Reset fields for next entry
    _startTimeController.clear();
    _endTimeController.clear();
    _noteController.clear();
    _taskIdController.clear();
    _taskNameController.clear();
    _projectIdController.clear();
    _projectNameController.clear();
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
    _selectedType = 'Non-Billable';
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Entry added (${_entries.length} total)")),
  );
}
```

---

## Step 6: Add Save Function - Convert to JSON String

**Add this new function to `_RequestTimeEntriesScreenState`:**

```dart
void _saveAllEntries() {
  if (_entries.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add at least one entry")),
    );
    return;
  }

  // Convert entries to JSON list
  final List<Map<String, dynamic>> jsonEntries = 
      _entries.map((entry) => entry.toJson()).toList();

  // Convert to JSON string (exactly like API format)
  final String jsonString = jsonEncode(jsonEntries);

  debugPrint('JSON String: $jsonString');

  // Store for server submission
  final timeEntryData = jsonString;

  // Example output:
  // [{"Username":"Abhay Singh Patel","User_ID":"17682000000114004",...}]

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("${_entries.length} entries ready to send")),
  );

  // TODO: Send timeEntryData to server API
  // API endpoint and headers will be added here
}
```

**Add this import at top of file:**

```dart
import 'dart:convert';
```

---

## Step 7: Add Form Fields for Task & Project

**In the build() method's form, add these fields after the Note field:**

```dart
const SizedBox(height: 20),

// Task ID field
CustomInputField(
  controller: _taskIdController,
  labelText: 'Task ID',
  hintText: 'Enter task ID',
  prefixIcon: Icons.assignment_outlined,
),
const SizedBox(height: 20),

// Task Name field
CustomInputField(
  controller: _taskNameController,
  labelText: 'Task Name',
  hintText: 'Enter task name',
  prefixIcon: Icons.assignment_outlined,
),
const SizedBox(height: 20),

// Project ID field
CustomInputField(
  controller: _projectIdController,
  labelText: 'Project ID',
  hintText: 'Enter project ID',
  prefixIcon: Icons.folder_outlined,
),
const SizedBox(height: 20),

// Project Name field
CustomInputField(
  controller: _projectNameController,
  labelText: 'Project Name',
  hintText: 'Enter project name',
  prefixIcon: Icons.folder_outlined,
),
```

---

## Step 8: Update Button Logic

**Find the ADD button's `onPressed` parameter.**

**Replace with:**

```dart
onPressed: (TimerService.instance.isRunning) ? null : _addTimeEntry,
```

---

## Step 9: Add Entries List Display

**Before the buttons, add this to show all added entries:**

```dart
const SizedBox(height: 20),

if (_entries.isNotEmpty)
  Container(
    margin: const EdgeInsets.symmetric(vertical: 20),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: customColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: customColors.inputBorder!, width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Added Entries (${_entries.length})',
          style: TextStyle(
            color: customColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._entries.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.value.taskName} (${entry.value.type})',
                        style: TextStyle(
                          color: customColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${entry.value.startTime} - ${entry.value.endTime} (${entry.value.totalTime} min)',
                        style: TextStyle(
                          color: customColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Remove'),
                      onTap: () {
                        setState(() => _entries.removeAt(entry.key));
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  ),
```

---

## Step 10: Update Button Row

**Replace the entire button row with this:**

```dart
const SizedBox(height: 20),

// Add Entry Button + Save Button
Row(
  children: [
    Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: customColors.primary!.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: (TimerService.instance.isRunning) ? null : _addTimeEntry,
          style: ElevatedButton.styleFrom(
            backgroundColor: customColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: const Text(
            'ADD ENTRY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),
    if (_entries.isNotEmpty)
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _saveAllEntries,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              'SAVE (${_entries.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    if (_entries.isEmpty)
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: customColors.error,
            side: BorderSide(color: customColors.error!, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'CANCEL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
  ],
),

const SizedBox(height: 12),
```
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: customColors.error,
            side: BorderSide(color: customColors.error!, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'CANCEL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
  ],
),

const SizedBox(height: 12),
```

---

## Step 11: Verify Implementation

**Checklist:**

- [ ] TimeEntry model has `toJson()` method
- [ ] `_calculateTotalMinutes()` function added
- [ ] All controllers initialized in `initState()`
- [ ] Form fields added for Task ID, Task Name, Project ID, Project Name
- [ ] `_addTimeEntry()` creates entries with all fields including totalTime
- [ ] `_saveAllEntries()` converts entries to JSON string
- [ ] JSON string format matches API exactly
- [ ] Entries list displays with remove option
- [ ] SAVE button shows count and calls `_saveAllEntries()`

---

## Step 12: Test Flow

1. Fill all form fields (date, times, type, note, task, project)
2. Click "ADD ENTRY" → Entry added, form resets, list shows entry
3. Repeat for 2-3 entries
4. Click "SAVE (3)" → Entries converted to JSON string
5. Check debug console for output:

```json
[{"Username":"...","User_ID":"...","Entry_Date":"2026-03-03",...}]
```

6. Ready to send to server API

---

## JSON Output Format

**Your entries will be converted to this format:**

```json
[{
  "Username":"Abhay Singh Patel",
  "User_ID":"17682000000114004",
  "Entry_Date":"2026-03-03",
  "Note":"l",
  "Type":"Non-Billable",
  "Start_time":"11:55 AM",
  "End_time":"2:54 PM",
  "Total_time":179,
  "Task_ID":"17682000000890878",
  "Task_Name":"sample",
  "Project_ID":"17682000000712517",
  "Project_Name":"test aman manager"
}]
```

**Sent as single string to server.**

