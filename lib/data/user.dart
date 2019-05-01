class User {
  int id;
  String username;
  String avatarUrl;

  User(this.id, this.username, this.avatarUrl);

  static User fromJson(Map<String, dynamic> jsonMap) {
    User user = new User(jsonMap["id"], jsonMap["login"], jsonMap["avatar_url"]);
    return user;
  }

}