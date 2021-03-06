class MarketAdvances {
  final int declines;
  final int advances;
  final int unchanged;

  MarketAdvances({this.declines, this.advances, this.unchanged});

  factory MarketAdvances.fromJson(Map<String, dynamic> json) {
    return MarketAdvances(
      declines: int.parse(json['declines']),
      advances: int.parse(json['advances']),
      unchanged: int.parse(json['unchanged']),
    );
  }
}
