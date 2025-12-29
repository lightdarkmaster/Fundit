class Goal {
  final int? id;
  final String name;
  final double price;
  final double saved;
  final String? imagePath;
  final DateTime? createdAt;
  final String? description;
  final String? priority;
  final DateTime? estimatedDate;

  Goal({
    this.id,
    required this.name,
    required this.price,
    required this.saved,
    this.imagePath,
    this.createdAt,
    this.description,
    this.priority,
    this.estimatedDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'saved': saved,
    'imagePath': imagePath,
    'createdAt': createdAt?.toIso8601String(),
    'description': description,
    'priority': priority,
    'estimatedDate': estimatedDate?.toIso8601String(),
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
    priority: map['priority'] ?? 'Low',
    estimatedDate: map['estimatedDate'] != null
        ? DateTime.parse(map['estimatedDate'])
        : null,
  );

  double get remaining => price - saved;
}
