class Goal {
  final int? id;
  final String name;
  final double price;
  final double saved;
  final String? imagePath;

  Goal({
    this.id,
    required this.name,
    required this.price,
    required this.saved,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'saved': saved,
    'imagePath': imagePath,
  };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    id: map['id'],
    name: map['name'],
    price: map['price'],
    saved: map['saved'],
    imagePath: map['imagePath'],
  );

  double get remaining => (price - saved).clamp(0, double.infinity);
}
