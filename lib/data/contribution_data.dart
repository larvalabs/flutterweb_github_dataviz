class ContributionData {
  int weekTime;
  int add;
  int delete;
  int change;

  ContributionData(this.weekTime, this.add, this.delete, this.change);

  static ContributionData fromJson(Map<String, dynamic> jsonMap) {
    ContributionData data = new ContributionData(jsonMap["w"], jsonMap["a"], jsonMap["d"], jsonMap["c"]);
//    print("Parsed contribution data for week ${data.weekTime}");
    return data;
  }

}