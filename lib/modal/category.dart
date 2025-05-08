


class Category {
  final String id;
  final String name;
  final String description;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
  });

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
      id: id,
      name: map['name'] ?? "",
      description: map['description'] ?? "",
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null, // Handle null case for createdAt
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(), // Convert DateTime to string
    };
  }

  Category copyWith({
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt, // Use passed createdAt or fallback to original
    );
  }
}
