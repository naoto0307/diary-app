import 'package:flutter/material.dart';

import '../data/entry_repository.dart';
import '../models/entry.dart';

class EntryEditScreen extends StatefulWidget {
  const EntryEditScreen({super.key, this.entry});

  /// null means "create a new entry"; non-null means "edit this entry".
  final Entry? entry;

  @override
  State<EntryEditScreen> createState() => _EntryEditScreenState();
}

class _EntryEditScreenState extends State<EntryEditScreen> {
  final _repository = EntryRepository();
  late final TextEditingController _controller = TextEditingController(
    text: widget.entry?.body ?? '',
  );

  bool get _isEditing => widget.entry != null;
  bool get _isDirty => _controller.text != (widget.entry?.body ?? '');

  Future<bool> _confirmDiscard() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('編集内容を破棄しますか?'),
            content: const Text('保存されていない内容は失われます。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('破棄', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handlePopInvoked(bool didPop) async {
    if (didPop) return;
    final discard = await _confirmDiscard();
    if (!discard || !mounted) return;
    Navigator.pop(context);
  }

  Future<void> _handleCancel() async {
    if (!_isDirty) {
      Navigator.pop(context);
      return;
    }
    final discard = await _confirmDiscard();
    if (discard && mounted) Navigator.pop(context);
  }

  Future<void> _handleSave() async {
    final body = _controller.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('本文を入力してください')));
      return;
    }

    if (_isEditing) {
      final updated = widget.entry!.copyWith(
        body: body,
        updatedAt: DateTime.now(),
      );
      await _repository.update(updated);
    } else {
      await _repository.insert(Entry.newEntry(body));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) => _handlePopInvoked(didPop),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? '編集' : '新規作成'),
          leading: TextButton(
            onPressed: _handleCancel,
            child: const Text('キャンセル', softWrap: false),
          ),
          leadingWidth: 96,
          actions: [
            TextButton(onPressed: _handleSave, child: const Text('保存')),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            maxLines: null,
            minLines: 10,
            expands: false,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: '今日の出来事を書いてみましょう',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}
