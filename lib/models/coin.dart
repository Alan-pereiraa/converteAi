class Coin {
  const Coin(this.code, this.name);

  final String code;
  final String name;

 static const List<Coin> available = [
    Coin('BRL', 'Real Brasileiro'),
    Coin('USD', 'Dólar Americano'),
    Coin('EUR', 'Euro'),
    Coin('GBP', 'Libra Esterlina'),
  ];
}
