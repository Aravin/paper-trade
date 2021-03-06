import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:paper_trade/models/market_advances.dart';
import 'dart:convert' as convert;

import 'package:paper_trade/models/market_data.dart';
import 'package:paper_trade/models/market_details.dart';

const url = 'https://www.nseindia.com/api/equity-stockIndices?index=NIFTY%2050';

const headers = {
  "user-agent":
      "Mozilla/5.0 (Linux; Android 6.0.1; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Mobile Safari/537.36",
  'authority': "www.nseindia.com",
  'schema': "https",
};

int retryCount = 10;
int retryDelay = 500;

Future<MarketDetails> getMarketData() async {
  int currentRetry = 0;
  for (;;) {
    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData =
            convert.jsonDecode(response.body)['data'] as List<dynamic>;

        var jsonStat = convert.jsonDecode(response.body)['advance'];
        String marketStatus = convert.jsonDecode(response.body)['marketStatus']
            ['marketStatus'] as String;
        String timestamp =
            convert.jsonDecode(response.body)['timestamp'] as String;

        List<MarketData> marketData =
            jsonData.map((i) => MarketData.fromJson(i)).toList();
        MarketAdvances marketStat = MarketAdvances.fromJson(jsonStat);

        return MarketDetails(
          timestamp: timestamp,
          marketStatus: marketStatus,
          marketAdvances: marketStat,
          marketData: marketData,
        );
      } else {
        throw response;
      }
    } catch (ex) {
      currentRetry++;
      debugPrint('retry ${currentRetry}');

      if (currentRetry > retryCount) {
        // If this isn't a transient error or we shouldn't retry,
        // rethrow the exception.
        debugPrint('retry exceeded');
        return MarketDetails(
          timestamp: '',
          marketStatus: 'failed',
          marketAdvances: MarketAdvances(),
          marketData: [],
        );
      }

      await Future.delayed(Duration(milliseconds: retryDelay * currentRetry));
    }
  }
}
