import 'package:calinout/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Why test pure functions first ─────────────────────────────────────────────
// Pure functions take inputs and return outputs with no side effects.
// No mocks, no async, no setup. They run in microseconds.
// isSameDay is used in DailyLogController.updateWeight to decide whether
// to use the current state or fetch a log from the API.
// If this returns a wrong result, the wrong log gets updated silently.
void main() {
  group('isSameDay', () {
    // ── Test 1 ────────────────────────────────────────────────────────────────
    // What: same date, same time → true
    // Why: the most basic case. If this fails nothing else matters.
    test('returns true for identical dates', () {
      final a = DateTime(2025, 6, 15, 10, 30);
      final b = DateTime(2025, 6, 15, 10, 30);

      expect(isSameDay(a, b), isTrue);
    });

    // ── Test 2 ────────────────────────────────────────────────────────────────
    // What: same date, different times → true
    // Why: this is the real use case. "Is this log from today?"
    // The user logs weight at 08:00 and edits it at 22:00 — still same day.
    // The function must ignore the time component entirely.
    test('returns true for same day different times', () {
      final a = DateTime(2025, 6, 15, 8, 0);
      final b = DateTime(2025, 6, 15, 22, 45);

      expect(isSameDay(a, b), isTrue);
    });

    // ── Test 3 ────────────────────────────────────────────────────────────────
    // What: consecutive days → false
    // Why: the most common false case. Yesterday's log must not be
    // treated as today's. This guards against the wrong log being updated.
    test('returns false for consecutive days', () {
      final a = DateTime(2025, 6, 15);
      final b = DateTime(2025, 6, 16);

      expect(isSameDay(a, b), isFalse);
    });

    // ── Test 4 ────────────────────────────────────────────────────────────────
    // What: year boundary — Dec 31 vs Jan 1 → false
    // Why: boundary conditions are where bugs hide.
    // Same day and month (31 and 1 are different) but the year check
    // must also pass independently.
    test('returns false across year boundary', () {
      final a = DateTime(2024, 12, 31);
      final b = DateTime(2025, 1, 1);

      expect(isSameDay(a, b), isFalse);
    });

    // ── Test 5 ────────────────────────────────────────────────────────────────
    // What: same day different months → false
    // Why: tests that month comparison works independently of day.
    // Day 15 of June vs day 15 of July — same day number, different month.
    test('returns false for same day number in different months', () {
      final a = DateTime(2025, 6, 15);
      final b = DateTime(2025, 7, 15);

      expect(isSameDay(a, b), isFalse);
    });
  });
}
