import 'dart:async';

import 'package:paper_trade/models/market_details.dart';
import 'package:paper_trade/shared/http.dart';
import 'package:paper_trade/shared/marketStatus.dart';

Stream<MarketDetails> getMarketDataApp() async* {
  int _counter = 0;
  // initilize
  MarketDetails _marketDetails = await getMarketData();

  // run the job on configured time
  Timer.periodic(Duration(seconds: 2), (Timer t) async {
    if (isMarketOpen()) {
      MarketDetails _marketDataTemp = await getMarketData();

      if (_counter > 0 &&
          _marketDataTemp.marketData != null &&
          _marketDataTemp.marketData.length > 0) {
        _marketDetails = _marketDataTemp;
      }
    }
  });

  // _marketDetails.marketData.insert(0, _nifty50);
  // counter to check if its first time load
  // _marketStream.add(_marketDetails);
  _counter++;

  yield _marketDetails;
}
