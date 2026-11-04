import 'package:flutter/material.dart';

import '../models/cotacao.dart';
import '../service/cotacao_service.dart';
import '../widgets/coin_selector.dart';
import '../widgets/result_card.dart';
import '../widgets/value_field.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key, this.service});

  final CotacaoService? service;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  late final CotacaoService _service = widget.service ?? CotacaoService();

  String _origin = 'USD';
  String _destination = 'BRL';
  bool _loading = false;
  String? _error;
  double? _resultValue;
  Cotacao? _cotacao;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _changeFields(VoidCallback change) {
    setState(() {
      change();
      _error = null;
      _cotacao = null;
      _resultValue = null;
    });
  }

  void _swapCoins() {
    _changeFields(() {
      final previousOrigin = _origin;
      _origin = _destination;
      _destination = previousOrigin;
    });
  }

  Future<void> _convert() async {
    if (!_formKey.currentState!.validate()) return;

    if (_origin == _destination) {
      setState(() => _error = 'Escolha moedas diferentes.');
      return;
    }

    final value = ValueField.parse(_valueController.text)!;
    setState(() {
      _loading = true;
      _error = null;
      _cotacao = null;
      _resultValue = null;
    });

    try {
      final cotacao = await _service.fetch(_origin, _destination);
      if (!mounted) return;
      setState(() {
        _cotacao = cotacao;
        _resultValue = value;
      });
    } on CotacaoException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cotacao = _cotacao;
    final resultValue = _resultValue;
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: const Text('ConverteAí')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ValueField(
                      controller: _valueController,
                      enabled: !_loading,
                      onChanged: (_) => _changeFields(() {}),
                    ),
                    const SizedBox(height: 16),
                    CoinSelector(
                      label: 'De',
                      code: _origin,
                      enabled: !_loading,
                      onChanged: (code) => _changeFields(() => _origin = code),
                    ),
                    Center(
                      child: IconButton(
                        tooltip: 'Inverter moedas',
                        icon: const Icon(Icons.swap_vert),
                        onPressed: _loading ? null : _swapCoins,
                      ),
                    ),
                    CoinSelector(
                      label: 'Para',
                      code: _destination,
                      enabled: !_loading,
                      onChanged: (code) =>
                          _changeFields(() => _destination = code),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading ? null : _convert,
                      child: const Text('Converter'),
                    ),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(child: CircularProgressIndicator()),
                    if (error != null)
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (cotacao != null && resultValue != null)
                      ResultCard(value: resultValue, cotacao: cotacao),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
