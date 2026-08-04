import 'package:diary_app/data/entry_repository.dart';
import 'package:diary_app/models/entry.dart';
import 'package:diary_app/screens/entry_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// A synchronous in-memory stand-in for [EntryRepository] so this widget
/// test only exercises rendering logic; the real sqflite-backed repository
/// is covered separately in entry_repository_test.dart.
class _FakeEntryRepository extends EntryRepository {
  _FakeEntryRepository(this._entries);

  final List<Entry> _entries;

  @override
  Future<List<Entry>> getAll() async => List.of(_entries);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  testWidgets('shows empty state when there are no entries', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: EntryListScreen(repository: _FakeEntryRepository([]))),
    );
    await tester.pumpAndSettle();

    expect(find.text('まだ日記がありません'), findsOneWidget);
    expect(find.text('最初の日記を書く'), findsOneWidget);
  });

  testWidgets('shows formatted date and truncated preview for a seeded entry', (
    tester,
  ) async {
    final longBody = 'あ' * 60;
    final repository = _FakeEntryRepository([
      Entry(
        id: 'seed-1',
        body: longBody,
        createdAt: DateTime(2026, 8, 4),
        updatedAt: DateTime(2026, 8, 4),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: EntryListScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026年8月4日'), findsOneWidget);
    expect(find.text('${'あ' * 40}…'), findsOneWidget);
    expect(find.text('まだ日記がありません'), findsNothing);
  });
}
