class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String status;
  final bool isOnline;
  final String lastSeen;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.status = 'Hey there! I am using ChatApp',
    this.isOnline = false,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      status: map['status'] ?? 'Hey there! I am using ChatApp',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? '',
    );
  }
}