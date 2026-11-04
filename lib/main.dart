import 'package:flutter/material.dart';

import 'pages/converter_page.dart';

void main() {
  runApp(const ConverteAiApp());
}

class ConverteAiApp extends StatelessWidget {
  const ConverteAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConverteAí',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const ConverterPage(),
    );
  }
}
