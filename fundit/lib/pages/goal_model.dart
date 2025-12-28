class Goal {
  final int? id;
  final String name;
  final double price;
  final double saved;
  final String? imagePath;
  final DateTime? createdAt;

  Goal({
    this.id,
    required this.name,
    required this.price,
    required this.saved,
    this.imagePath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'saved': saved,
    'imagePath': imagePath,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    id: map['id'],
    name: map['name'],
    price: map['price'],
    saved: map['saved'],
    imagePath: map['imagePath'],
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : null,
  );

  double get remaining => price - saved;
}
