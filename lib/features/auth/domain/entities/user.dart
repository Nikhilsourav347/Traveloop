/// Pure domain entity – no Firebase dependency whatsoever
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };

  factory UserEntity.fromMap(Map<String, dynamic> map) => UserEntity(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        photoUrl: map['photoUrl'] as String?,
      );
}
