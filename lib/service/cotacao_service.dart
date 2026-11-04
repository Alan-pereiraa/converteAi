import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cotacao.dart';

class CotacaoException implements Exception {
  const CotacaoException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CotacaoService {
  CotacaoService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://economia.awesomeapi.com.br';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  Future<Cotacao> fetch(String origin, String destination) async {
    final uri = Uri.parse('$_baseUrl/json/last/$origin-$destination');

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const CotacaoException('A consulta demorou demais. Tente novamente.');
    } on http.ClientException {
      throw const CotacaoException('Sem conexão com o serviço de cotações.');
    }

    if (response.statusCode == 404) {
      throw CotacaoException('Cotação indisponível para $origin-$destination.');
    }
    if (response.statusCode != 200) {
      throw const CotacaoException('Não foi possível consultar a cotação.');
    }

    try {
      final body = jsonDecode(response.body);
      final data = body is Map ? body['$origin$destination'] : null;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Pair missing from response');
      }
      return Cotacao.fromJson(data);
    } on FormatException {
      throw const CotacaoException('A resposta da API veio em formato inesperado.');
    }
  }
}
