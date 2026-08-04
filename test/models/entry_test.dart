import 'package:diary_app/models/entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Entry', () {
    test('newEntry generates a UUID and equal created/updated timestamps', () {
      final entry = Entry.newEntry('hello');

      expect(entry.id, isNotEmpty);
      expect(entry.body, 'hello');
      expect(entry.createdAt, entry.updatedAt);
    });

    test('toMap/fromMap round-trip preserves all fields', () {
      final original = Entry.newEntry('today was good');
      final restored = Entry.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.body, original.body);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('copyWith preserves id/createdAt and only updates body/updatedAt', () {
      final original = Entry.newEntry('draft');
      final later = original.createdAt.add(const Duration(minutes: 5));

      final updated = original.copyWith(
        body: 'final version',
        updatedAt: later,
      );

      expect(updated.id, original.id);
      expect(updated.createdAt, original.createdAt);
      expect(updated.body, 'final version');
      expect(updated.updatedAt, later);
    });

    test('copyWith with no args keeps everything the same', () {
      final original = Entry.newEntry('unchanged');
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.body, original.body);
      expect(copy.createdAt, original.createdAt);
      expect(copy.updatedAt, original.updatedAt);
    });
  });
}
