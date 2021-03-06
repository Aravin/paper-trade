import 'package:paper_trade/models/market_advances.dart';
import 'package:paper_trade/models/market_data.dart';

class MarketDetails {
  final String timestamp;
  final String marketStatus;
  final MarketAdvances marketAdvances;
  final List<MarketData> marketData;

  MarketDetails({
    this.timestamp,
    this.marketStatus,
    this.marketAdvances,
    this.marketData,
  });

  factory MarketDetails.fromJson(Map<String, dynamic> json) {
    return MarketDetails(
      timestamp: json['timestamp'],
      marketStatus: json['marketStatus'],
      marketAdvances: json['marketAdvances'],
      marketData: json['marketData'],
    );
  }
}
