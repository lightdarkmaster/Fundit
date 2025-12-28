class Goal {
  final int? id;
  final String name;
  final double price;
  final double saved;
  final String? imagePath;
  final DateTime? createdAt;
  final String? description;

  Goal({
    this.id,
    required this.name,
    required this.price,
    required this.saved,
    this.imagePath,
    this.createdAt,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'saved': saved,
    'imagePath': imagePath,
    'createdAt': createdAt?.toIso8601String(),
    'description': description,
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
    description: map['description'],
  );

  double get remaining => price - saved;
}
