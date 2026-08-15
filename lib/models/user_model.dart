class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String address;
  final String role; // 'admin' or 'customer'
  final String? avatarUrl;
  final String? fcmToken;
  final int points;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.address,
    required this.role,
    this.avatarUrl,
    this.fcmToken,
    this.points = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'address': address,
      'role': role,
      'avatarUrl': avatarUrl,
      'fcmToken': fcmToken,
      'points': points,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? 'customer',
      avatarUrl: map['avatarUrl'],
      fcmToken: map['fcmToken'],
      points: map['points'] ?? 0,
    );
  }
}
