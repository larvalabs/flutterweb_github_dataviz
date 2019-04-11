class User {
  /**
   *
   *  "author": {
      "login": "jamesderlin",
      "id": 17391434,
      "node_id": "MDQ6VXNlcjE3MzkxNDM0",
      "avatar_url": "https://avatars3.githubusercontent.com/u/17391434?v=4",
      "gravatar_id": "",
      "url": "https://api.github.com/users/jamesderlin",
      "html_url": "https://github.com/jamesderlin",
      "followers_url": "https://api.github.com/users/jamesderlin/followers",
      "following_url": "https://api.github.com/users/jamesderlin/following{/other_user}",
      "gists_url": "https://api.github.com/users/jamesderlin/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/jamesderlin/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/jamesderlin/subscriptions",
      "organizations_url": "https://api.github.com/users/jamesderlin/orgs",
      "repos_url": "https://api.github.com/users/jamesderlin/repos",
      "events_url": "https://api.github.com/users/jamesderlin/events{/privacy}",
      "received_events_url": "https://api.github.com/users/jamesderlin/received_events",
      "type": "User",
      "site_admin": false
      }
   */

  int id;
  String username;
  String avatarUrl;

  User(this.id, this.username, this.avatarUrl);

  static User fromJson(Map<String, dynamic> jsonMap) {
    User user = new User(jsonMap["id"], jsonMap["login"], jsonMap["avatar_url"]);
//    print("Parsed user ${user.id}");
    return user;
  }

}