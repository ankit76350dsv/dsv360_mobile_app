# Fix Guide: `The value of 'refresh' should be used` (`dartunused_result`)

## Goal
Fix this warning in Riverpod code:

```dart
ref.refresh(someProvider);
```

when the return value is not used.

## Smallest Possible Steps (In Sequence)

1. Find every `ref.refresh(...)` call that is used only as a statement.
Why: The warning appears only when `refresh` returns a value and that value is ignored.

2. Decide intent for each call:
- Intent A: You only want to trigger a reload/rebuild side effect.
- Intent B: You need the refreshed value immediately in code.
Why: `refresh` and `invalidate` are used differently; choosing the wrong one can change behavior.

3. If intent is A (side effect only), replace:

```dart
ref.refresh(myProvider);
```

with:

```dart
ref.invalidate(myProvider);
```

Why: `invalidate` is the correct side-effect API and avoids the unused return warning.

4. If intent is B (you need the value), keep `refresh` and consume its result.
Examples:

```dart
final value = ref.refresh(myProvider);
useValue(value);
```

or

```dart
return ref.refresh(myProvider);
```

Why: The lint requires the returned value to be used.

5. Special case for pull-to-refresh (`RefreshIndicator`): keep using future refresh result.
Use:

```dart
onRefresh: () async {
	return await ref.refresh(myProvider.future);
}
```

Why: `RefreshIndicator` expects a `Future`; this consumes the returned future correctly.

6. Re-run analyzer and confirm warning is gone.
Why: Ensures every offending `refresh` usage is fixed and no new lint appears.

## Quick Decision Rule

- Use `ref.invalidate(provider)` when you just want to trigger recomputation.
- Use `ref.refresh(provider)` only when you also use/return the refreshed value.

## Example Transformations

### A) Button click (no value needed)

Before:

```dart
onPressed: () => ref.refresh(issueListProvider),
```

After:

```dart
onPressed: () => ref.invalidate(issueListProvider),
```

Why: Click action needs reload side effect, not a returned value.

### B) Inside async flow (no value needed)

Before:

```dart
if (result == true) {
	ref.refresh(projectListProvider);
}
```

After:

```dart
if (result == true) {
	ref.invalidate(projectListProvider);
}
```

Why: Same side effect, warning removed.

### C) You really need refreshed data now

Before:

```dart
ref.refresh(userProvider);
```

After:

```dart
final user = ref.refresh(userProvider);
handleUser(user);
```

Why: Returned value is now consumed, so no `dartunused_result` warning.
