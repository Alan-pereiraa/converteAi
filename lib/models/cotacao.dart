class Cotacao {
  const Cotacao({
    required this.origin,
    required this.destination,
    required this.bid,
  });

  factory Cotacao.fromJson(Map<String, dynamic> json) {
    return Cotacao(
      origin: json['code'].toString(),
      destination: json['codein'].toString(),
      bid: double.parse(json['bid'].toString()),
    );
  }

  final String origin;
  final String destination;

  final double bid;
}
