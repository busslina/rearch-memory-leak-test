class Character {
  const Character({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.avatar,
  });

  factory Character.fromJson(Map<String, dynamic> data) => Character(
    id: data['id'] as String,
    createdAt: DateTime.parse(data['createdAt'] as String),
    name: data['name'] as String,
    avatar: data['avatar'] as String,
  );

  final String id;
  final DateTime createdAt;
  final String name;
  final String avatar;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'avatar': avatar,
  };
}
