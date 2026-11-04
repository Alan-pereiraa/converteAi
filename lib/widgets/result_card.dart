import 'package:flutter/material.dart';

import '../models/cotacao.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.value, required this.cotacao});

  final double value;
  final Cotacao cotacao;

  String _format(double number, int decimals) =>
      number.toStringAsFixed(decimals).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final converted = value * cotacao.bid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${_format(value, 2)} ${cotacao.origin} =',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${_format(converted, 2)} ${cotacao.destination}',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cotação: 1 ${cotacao.origin} = '
              '${_format(cotacao.bid, 4)} ${cotacao.destination}',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
