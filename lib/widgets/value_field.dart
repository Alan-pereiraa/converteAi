import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ValueField extends StatelessWidget {
  const ValueField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  static final _pattern = RegExp(r'^\d{0,12}([,.]\d{0,2})?$');

  static double? parse(String text) =>
      double.tryParse(text.replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        TextInputFormatter.withFunction(
          (previous, next) => _pattern.hasMatch(next.text) ? next : previous,
        ),
      ],
      decoration: const InputDecoration(
        labelText: 'Valor',
        border: OutlineInputBorder(),
      ),
      validator: (text) {
        final value = parse(text ?? '');
        if (value == null || value <= 0) {
          return 'Informe um valor maior que zero';
        }
        return null;
      },
    );
  }
}
