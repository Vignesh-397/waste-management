class UserModel {
  String uid;
  String email;
  String role;

  UserModel({required this.uid, required this.email, required this.role});

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'role': role};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(uid: map['uid'], email: map['email'], role: map['role']);
  }
}
