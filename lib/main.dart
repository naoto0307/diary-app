import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/entry_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');
  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日記',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const EntryListScreen(),
    );
  }
}
