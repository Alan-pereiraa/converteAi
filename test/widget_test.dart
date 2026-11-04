import 'dart:convert';

import 'package:converteai/pages/converter_page.dart';
import 'package:converteai/service/cotacao_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Future<void> abrirPagina(WidgetTester tester, MockClient client) {
    return tester.pumpWidget(
      MaterialApp(
        home: ConverterPage(service: CotacaoService(client: client)),
      ),
    );
  }

  MockClient respostaUsdBrl() {
    return MockClient((request) async {
      expect(request.url.path, '/json/last/USD-BRL');
      return http.Response(
        jsonEncode({
          'USDBRL': {'code': 'USD', 'codein': 'BRL', 'bid': '5.4882'},
        }),
        200,
      );
    });
  }

  Future<void> converter(WidgetTester tester) async {
    await tester.tap(find.text('Converter'));
    await tester.pumpAndSettle();
  }

  testWidgets('converte o valor usando o bid da API', (tester) async {
    await abrirPagina(tester, respostaUsdBrl());

    await tester.enterText(find.byType(TextFormField), '100,50');
    await converter(tester);

    expect(find.text('100,50 USD ='), findsOneWidget);
    expect(find.text('551,56 BRL'), findsOneWidget);
    expect(find.text('Cotação: 1 USD = 5,4882 BRL'), findsOneWidget);
  });

  testWidgets('descarta o resultado quando o valor muda', (tester) async {
    await abrirPagina(tester, respostaUsdBrl());

    await tester.enterText(find.byType(TextFormField), '100');
    await converter(tester);
    expect(find.text('548,82 BRL'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '200');
    await tester.pump();

    expect(find.text('548,82 BRL'), findsNothing);
  });

  testWidgets('não aceita mais de duas casas decimais', (tester) async {
    await abrirPagina(tester, respostaUsdBrl());

    await tester.enterText(find.byType(TextFormField), '1.000');
    await tester.pump();

    expect(find.text('1.000'), findsNothing);
  });

  testWidgets('não consulta a API com valor inválido', (tester) async {
    var chamadas = 0;
    await abrirPagina(
      tester,
      MockClient((request) async {
        chamadas++;
        return http.Response('{}', 200);
      }),
    );

    await converter(tester);

    expect(find.text('Informe um valor maior que zero'), findsOneWidget);
    expect(chamadas, 0);
  });

  testWidgets('não consulta a API com moedas iguais', (tester) async {
    var chamadas = 0;
    await abrirPagina(
      tester,
      MockClient((request) async {
        chamadas++;
        return http.Response('{}', 200);
      }),
    );

    await tester.enterText(find.byType(TextFormField), '10');
    await tester.tap(find.text('USD - Dólar Americano'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BRL - Real Brasileiro').last);
    await tester.pumpAndSettle();
    await converter(tester);

    expect(find.text('Escolha moedas diferentes.'), findsOneWidget);
    expect(chamadas, 0);
  });

  testWidgets('inverte as moedas na consulta', (tester) async {
    late Uri chamada;
    await abrirPagina(
      tester,
      MockClient((request) async {
        chamada = request.url;
        return http.Response(
          jsonEncode({
            'BRLUSD': {'code': 'BRL', 'codein': 'USD', 'bid': '0.2'},
          }),
          200,
        );
      }),
    );

    await tester.enterText(find.byType(TextFormField), '10');
    await tester.tap(find.byTooltip('Inverter moedas'));
    await tester.pump();
    await converter(tester);

    expect(chamada.path, '/json/last/BRL-USD');
    expect(find.text('2,00 USD'), findsOneWidget);
  });

  testWidgets('mostra mensagem quando o par não existe', (tester) async {
    await abrirPagina(
      tester,
      MockClient((request) async => http.Response(
            '{"status":404,"code":"CoinNotExists"}',
            404,
          )),
    );

    await tester.enterText(find.byType(TextFormField), '10');
    await converter(tester);

    expect(find.text('Cotação indisponível para USD-BRL.'), findsOneWidget);
  });

  testWidgets('mostra mensagem quando não há conexão', (tester) async {
    await abrirPagina(
      tester,
      MockClient((request) async => throw http.ClientException('offline')),
    );

    await tester.enterText(find.byType(TextFormField), '10');
    await converter(tester);

    expect(find.text('Sem conexão com o serviço de cotações.'), findsOneWidget);
  });

  testWidgets('mostra mensagem quando a resposta é inesperada', (tester) async {
    await abrirPagina(
      tester,
      MockClient((request) async => http.Response('<html></html>', 200)),
    );

    await tester.enterText(find.byType(TextFormField), '10');
    await converter(tester);

    expect(
      find.text('A resposta da API veio em formato inesperado.'),
      findsOneWidget,
    );
  });
}
