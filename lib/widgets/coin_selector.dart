import 'package:flutter/material.dart';

import '../models/coin.dart';

class CoinSelector extends StatelessWidget {
  const CoinSelector({
    super.key,
    required this.label,
    required this.code,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String code;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: code,
          isExpanded: true,
          isDense: true,
          onChanged: enabled ? (selected) => onChanged(selected!) : null,
          items: [
            for (final coin in Coin.available)
              DropdownMenuItem(
                value: coin.code,
                child: Text('${coin.code} - ${coin.name}'),
              ),
          ],
        ),
      ),
    );
  }
}
