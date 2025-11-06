// 放纯数据模型
class User {
  final String userId;
  final bool? noDisturb;

  const User({required this.userId, this.noDisturb});
  // 通常带有 fromJson / toJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String, // 因为是dynamic 这里加as是保证类型安全
      noDisturb: json['noDisturb'] as bool?, // bool? 表示可为空
    );
  }
  Map<String, dynamic> toJson() => {
    'userId': userId, // dart中因为不存在全局变量 因此在不产生命名冲突时 可以省略this
    'noDisturb': noDisturb,
  };
  User copyWith({String? userId, bool? noDisturb}) => User(
    userId: userId ?? this.userId, // 这里跟局部变量有命名冲突 所以加this
    noDisturb: noDisturb ?? this.noDisturb,
  );
}
