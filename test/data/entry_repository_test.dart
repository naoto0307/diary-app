import 'package:diary_app/data/database_helper.dart';
import 'package:diary_app/data/entry_repository.dart';
import 'package:diary_app/models/entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Test-only [DatabaseHelper] that opens a fresh in-memory database per
/// instance instead of touching the platform-channel-backed sqflite plugin.
class _InMemoryDatabaseHelper extends DatabaseHelper {
  _InMemoryDatabaseHelper() : super.test();

  Database? _db;

  @override
  Future<Database> get database async => _db ??= await openDatabase(
    inMemoryDatabasePath,
    version: 1,
    singleInstance: false,
    onCreate: (db, version) => db.execute('''
          CREATE TABLE entries (
            id TEXT PRIMARY KEY,
            body TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        '''),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late EntryRepository repository;

  setUp(() {
    repository = EntryRepository(databaseHelper: _InMemoryDatabaseHelper());
  });

  group('EntryRepository', () {
    test('insert then getAll returns the entry', () async {
      final entry = Entry.newEntry('first entry');
      await repository.insert(entry);

      final all = await repository.getAll();

      expect(all, hasLength(1));
      expect(all.first.id, entry.id);
      expect(all.first.body, 'first entry');
    });

    test('getAll orders newest created_at first', () async {
      final older = Entry.newEntry('older').copyWith();
      final olderAdjusted = Entry(
        id: older.id,
        body: older.body,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final newer = Entry(
        id: 'newer-id',
        body: 'newer',
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      );

      await repository.insert(olderAdjusted);
      await repository.insert(newer);

      final all = await repository.getAll();

      expect(all.map((e) => e.id).toList(), [newer.id, olderAdjusted.id]);
    });

    test('getById returns the matching entry or null', () async {
      final entry = Entry.newEntry('findable');
      await repository.insert(entry);

      final found = await repository.getById(entry.id);
      final missing = await repository.getById('does-not-exist');

      expect(found?.body, 'findable');
      expect(missing, isNull);
    });

    test('update changes body/updatedAt but preserves id/createdAt', () async {
      final entry = Entry.newEntry('original body');
      await repository.insert(entry);

      final later = entry.createdAt.add(const Duration(hours: 1));
      final updated = entry.copyWith(body: 'edited body', updatedAt: later);
      await repository.update(updated);

      final fetched = await repository.getById(entry.id);

      expect(fetched?.body, 'edited body');
      expect(fetched?.updatedAt, later);
      expect(fetched?.createdAt, entry.createdAt);
      expect(fetched?.id, entry.id);
    });

    test('delete removes the row', () async {
      final entry = Entry.newEntry('to be deleted');
      await repository.insert(entry);

      await repository.delete(entry.id);

      final all = await repository.getAll();
      expect(all, isEmpty);
    });
  });
}
