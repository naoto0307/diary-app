import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/entry_repository.dart';
import '../models/entry.dart';
import 'entry_edit_screen.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key, required this.entry});

  final Entry entry;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final _repository = EntryRepository();
  late Entry _entry = widget.entry;

  Future<void> _openEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntryEditScreen(entry: _entry)),
    );
    final refreshed = await _repository.getById(_entry.id);
    if (refreshed != null && mounted) {
      setState(() => _entry = refreshed);
    }
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('日記を削除しますか?'),
            content: const Text('この操作は取り消せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleDelete() async {
    final confirmed = await _confirmDelete();
    if (!confirmed) return;
    await _repository.delete(_entry.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年M月d日', 'ja').format(_entry.createdAt)),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _openEdit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _handleDelete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _entry.body,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
