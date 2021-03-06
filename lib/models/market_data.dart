class MarketData {
  final int priority;
  final String companyName;
  final String industry;
  final String symbol;
  final String identifier;
  final double open;
  final double dayHigh;
  final double dayLow;
  final double lastPrice;
  final double previousClose;
  final double change;
  final double pChange;
  final double ffmc;
  final double yearHigh;
  final double yearLow;
  final double totalTradedVolume;
  final double totalTradedValue;
  final String lastUpdateTime;
  final double nearWKH;
  final double nearWKL;
  final double perChange365d;
  final String date365dAgo;
  final String chart365dPath;
  final String date30dAgo;
  final double perChange30d;
  final String chart30dPath;
  final String chartTodayPath;

  MarketData({
    this.priority,
    this.companyName,
    this.industry,
    this.symbol,
    this.identifier,
    this.open,
    this.dayHigh,
    this.dayLow,
    this.lastPrice,
    this.previousClose,
    this.change,
    this.pChange,
    this.ffmc,
    this.yearHigh,
    this.yearLow,
    this.totalTradedVolume,
    this.totalTradedValue,
    this.lastUpdateTime,
    this.nearWKH,
    this.nearWKL,
    this.perChange365d,
    this.date365dAgo,
    this.chart365dPath,
    this.date30dAgo,
    this.perChange30d,
    this.chart30dPath,
    this.chartTodayPath,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      priority: json['priority'] ?? 0,
      companyName: json['meta'] != null ? json['meta']['companyName'] : '',
      industry: json['meta'] != null ? json['meta']['industry'] : '',
      symbol: json['symbol'],
      identifier: json['identifier'],
      open: double.parse(json['open'].toStringAsFixed(2)),
      dayHigh: double.parse(json['dayHigh'].toStringAsFixed(2)),
      dayLow: double.parse(json['dayLow'].toStringAsFixed(2)),
      lastPrice: double.parse(json['lastPrice'].toStringAsFixed(2)),
      previousClose: double.parse(json['previousClose'].toStringAsFixed(2)),
      change: double.parse(json['change'].toStringAsFixed(2)),
      pChange: double.parse(json['pChange'].toStringAsFixed(2)),
      ffmc: double.parse(json['ffmc'].toStringAsFixed(2)),
      yearHigh: double.parse(json['yearHigh'].toStringAsFixed(2)),
      yearLow: double.parse(json['yearLow'].toStringAsFixed(2)),
      totalTradedVolume:
          double.parse(json['totalTradedVolume'].toStringAsFixed(2)),
      totalTradedValue:
          double.parse(json['totalTradedValue'].toStringAsFixed(2)),
      lastUpdateTime: json['lastUpdateTime'],
      nearWKH: double.parse(json['nearWKH'].toStringAsFixed(2)),
      nearWKL: double.parse(json['nearWKL'].toStringAsFixed(2)),
      perChange365d: double.parse(json['perChange365d'].toStringAsFixed(2)),
      date365dAgo: json['date365dAgo'],
      chart365dPath: json['chart365dPath'],
      date30dAgo: json['date30dAgo'],
      perChange30d: double.parse(json['perChange30d'].toStringAsFixed(2)),
      chart30dPath: json['chart30dPath'],
      chartTodayPath: json['chartTodayPath'],
    );
  }
}
