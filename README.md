# ConverteAí

Aplicativo em Flutter para conversão de câmbio entre moedas, usando as cotações da [API de Moedas da AwesomeAPI](https://docs.awesomeapi.com.br/api-de-moedas), uma API REST.

> **Status:** em desenvolvimento. O projeto ainda está na estrutura inicial do Flutter, e as funcionalidades abaixo descrevem o que se pretende construir.

## A ideia

A pessoa informa um valor, escolhe a moeda de origem e a de destino, e o app busca a cotação atual na API para calcular o valor convertido.

Por exemplo, para converter 100 dólares em reais com a cotação de compra (`bid`) a 5,40:

```
100 USD × 5,40 = 540,00 BRL
```

## Funcionalidades previstas

- Informar o valor a ser convertido
- Selecionar as moedas de origem e de destino
- Consultar a cotação atual pela API
- Exibir o valor convertido e a cotação utilizada

## API utilizada

**URL base:** `https://economia.awesomeapi.com.br`

O endpoint principal do projeto é o de última cotação, que aceita um ou mais pares de moedas separados por vírgula:

```
GET /json/last/:moedas
```

Exemplo: `GET https://economia.awesomeapi.com.br/json/last/USD-BRL`

A resposta é um objeto cuja chave é o par de moedas sem o hífen, e os valores numéricos vêm como texto:

```json
{
  "USDBRL": {
    "code": "USD",
    "codein": "BRL",
    "name": "Dólar Americano/Real Brasileiro",
    "high": "...",
    "low": "...",
    "varBid": "...",
    "pctChange": "...",
    "bid": "...",
    "ask": "...",
    "timestamp": "...",
    "create_date": "..."
  }
}
```

| Campo | Significado |
| --- | --- |
| `code` / `codein` | Moeda de origem / moeda de destino |
| `name` | Nome do par de moedas |
| `bid` / `ask` | Valor de compra / valor de venda |
| `high` / `low` | Valor máximo / valor mínimo |
| `varBid` / `pctChange` | Variação / porcentagem de variação |
| `timestamp` / `create_date` | Horário da negociação |

Para um par inexistente, a API responde com erro 404:

```json
{ "status": 404, "code": "CoinNotExists", "message": "moeda nao encontrada ABC-BRL" }
```

A lista de pares disponíveis está em [`/xml/available`](https://economia.awesomeapi.com.br/xml/available).

### Autenticação

O projeto usa a API sem chave de autenticação, então não é preciso criar conta nem configurar nada. Nesse modo, as respostas de `/json/last` ficam em cache por 1 minuto, ou seja, a cotação exibida pode ter até cerca de 1 minuto de atraso.

## Como executar

É preciso ter o [Flutter](https://docs.flutter.dev/get-started/install) instalado.

```bash
flutter pub get
flutter run
```

O projeto tem configuração para Android, iOS e Web.
