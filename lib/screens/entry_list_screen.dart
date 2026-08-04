import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/entry_repository.dart';
import '../models/entry.dart';
import 'entry_detail_screen.dart';
import 'entry_edit_screen.dart';

class EntryListScreen extends StatefulWidget {
  const EntryListScreen({super.key, this.repository});

  final EntryRepository? repository;

  @override
  State<EntryListScreen> createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<EntryListScreen> {
  late final EntryRepository _repository =
      widget.repository ?? EntryRepository();
  List<Entry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _repository.getAll();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EntryEditScreen()),
    );
    _loadEntries();
  }

  Future<void> _openDetail(Entry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: entry)),
    );
    _loadEntries();
  }

  String _preview(String body) {
    final singleLine = body.replaceAll('\n', ' ').trim();
    return singleLine.length > 40
        ? '${singleLine.substring(0, 40)}…'
        : singleLine;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日記')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? _EmptyState(onCreate: _openCreate)
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return ListTile(
                  title: Text(
                    DateFormat('yyyy年M月d日', 'ja').format(entry.createdAt),
                  ),
                  subtitle: Text(
                    _preview(entry.body),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _openDetail(entry),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('まだ日記がありません', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onCreate, child: const Text('最初の日記を書く')),
        ],
      ),
    );
  }
}
