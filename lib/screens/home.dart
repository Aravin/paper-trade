import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_trade/models/market_data.dart';
import 'package:paper_trade/models/market_details.dart';
import 'package:paper_trade/providers/provider.dart';
import 'package:paper_trade/screens/buysell.dart';
import 'package:paper_trade/shared/constants.dart';
import 'package:paper_trade/widgets/bottom_navigation_bar.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    Stream<MarketDetails> _marketStream = watch(marketDataProvider.stream);

    final searchController = TextEditingController();
    String _sortBy = 'sortAZ';
    String _searchStr = '';

    // MarketData _nifty50 =  _marketStream.toList();

    // // sort by
    // switch (_sortBy) {
    //   case 'sortAZ':
    //     _nifty50 = _marketDetails.marketData.elementAt(0);
    //     _marketDetails.marketData
    //         .sort((a, b) => (a.companyName).compareTo((b.companyName)));
    //     _marketDetails.marketData.removeAt(0);
    //     _marketDetails.marketData.insert(0, _nifty50);
    //     break;

    //   case 'sortZA':
    //     _nifty50 = _marketDetails.marketData.elementAt(0);
    //     _marketDetails.marketData
    //         .sort((a, b) => (b.companyName).compareTo((a.companyName)));
    //     _marketDetails.marketData.removeAt(0);
    //     _marketDetails.marketData.insert(0, _nifty50);
    //     break;

    //   case 'sortPriceLow':
    //     _nifty50 = _marketDetails.marketData.elementAt(0);
    //     _marketDetails.marketData
    //         .sort((a, b) => (a.lastPrice).compareTo((b.lastPrice)));
    //     _marketDetails.marketData.removeAt(0);
    //     _marketDetails.marketData.insert(0, _nifty50);
    //     break;

    //   case 'sortPriceHigh':
    //     _nifty50 = _marketDetails.marketData.elementAt(0);
    //     _marketDetails.marketData
    //         .sort((a, b) => (b.companyName).compareTo((a.companyName)));
    //     _marketDetails.marketData.removeAt(0);
    //     _marketDetails.marketData.insert(0, _nifty50);
    //     break;

    //   case 'sortPercentLow':
    //     _nifty50 = _marketDetails.marketData.elementAt(0);
    //     _marketDetails.marketData
    //         .sort((a, b) => (a.pChange).compareTo((b.pChange)));
    //     _marketDetails.marketData.removeAt(0);
    //     _marketDetails.marketData.insert(0, _nifty50);
    //     break;

    //   case 'sortPercentHigh':
    //     // _marketDetails?.then((x) => {
    //     _nifty50 = _marketDetails.marketData.elementAt(0);
    //     _marketDetails.marketData
    //         .sort((a, b) => (b.pChange).compareTo((a.pChange)));
    //     _marketDetails.marketData.removeAt(0);
    //     _marketDetails.marketData.insert(0, _nifty50);
    //     // });
    //     break;
    // }

    // // search
    // if (_searchStr != null && _searchStr != '') {
    //   print(_searchStr);
    //   _nifty50 = _marketDetails.marketData.elementAt(0);
    //   _marketDetails.marketData.filter((a) =>
    //       a.companyName
    //           .toString()
    //           .toLowerCase()
    //           .indexOf(_searchStr.toLowerCase()) !=
    //       -1);
    //   _marketDetails.marketData.removeAt(0);
    //   _marketDetails.marketData.insert(0, _nifty50);
    // }

    Future<bool> _onWillPop() async {
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to exit an App'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes'),
                ),
              ],
            ),
          )) ??
          false;
    }

    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: StreamBuilder<MarketDetails>(
            stream: _marketStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData &&
                  (snapshot.data.marketData == null ||
                      snapshot.data.marketData.length == 0)) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CircularProgressIndicator(),
                      HeightBox(20),
                      'Failed to get data from NSE India...'.text.make(),
                      ElevatedButton(
                        child: 'Reload'.text.make(),
                        onPressed: () {
                          // getMarketDataInternal();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      'INDEX'.text.extraBold.underline.widest.green500.make(),
                      snapshot.data?.marketStatus?.toLowerCase() == 'open'
                          ? 'Market Open'.text.bold.green500.make()
                          : 'Market Closed'.text.bold.red500.make(),
                    ],
                  ),
                  HeightBox(10),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 30,
                                width: 60,
                                child: Image.asset(
                                  'assets/images/stock/NIFTY50.PNG',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // Flexible(
                              //   child: Image.network(snapshot
                              //       .data?.marketData[0].chartTodayPath),
                              // ),
                              '???${snapshot.data?.marketData[0].lastPrice}'
                                  .text
                                  .semiBold
                                  .make(),
                            ],
                          ),
                          HeightBox(10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              snapshot.data.marketData[0].symbol.text.bold
                                  .make(),
                              snapshot.data.marketData[0].change
                                      .toString()
                                      .contains('-')
                                  ? '${snapshot.data?.marketData[0].change} (${snapshot.data?.marketData[0].pChange}%)'
                                      .text
                                      .semiBold
                                      .red500
                                      .make()
                                  : '${snapshot.data?.marketData[0].change} (${snapshot.data?.marketData[0].pChange}%)'
                                      .text
                                      .semiBold
                                      .green500
                                      .make(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      'STOCKS'.text.extraBold.underline.widest.green500.make(),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller: searchController,
                            textInputAction: TextInputAction.go,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search NIFTY50 Stocks',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onChanged: (String value) {
                              // setState(() {
                              //   _searchStr = value;
                              // });
                              // getMarketDataInternal();
                            },
                          ),
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.sort),
                        tooltip: 'Sort',
                        elevation: 25.0,
                        offset: Offset(25, 50),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'sortAZ',
                            child: _sortBy == 'sortAZ'
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sort by (A-Z)'),
                                      WidthBox(10.0),
                                      Icon(Icons.check_box_sharp,
                                          color: kSecondaryColor),
                                    ],
                                  )
                                : Text('Sort by (A-Z)'),
                          ),
                          PopupMenuItem<String>(
                            value: 'sortZA',
                            child: _sortBy == 'sortZA'
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sort by (Z-A)'),
                                      WidthBox(10.0),
                                      Icon(Icons.check_box_sharp,
                                          color: kSecondaryColor),
                                    ],
                                  )
                                : Text('Sort by (Z-A)'),
                          ),
                          PopupMenuItem<String>(
                            value: 'sortPriceLow',
                            child: _sortBy == 'sortPriceLow'
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sort by ??? (Low-High)'),
                                      WidthBox(10.0),
                                      Icon(Icons.check_box_sharp,
                                          color: kSecondaryColor),
                                    ],
                                  )
                                : Text('Sort by ??? (Low-High)'),
                          ),
                          PopupMenuItem<String>(
                            value: 'sortPriceHigh',
                            child: _sortBy == 'sortPriceHigh'
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sort by ??? (High-Low'),
                                      WidthBox(10.0),
                                      Icon(Icons.check_box_sharp,
                                          color: kSecondaryColor),
                                    ],
                                  )
                                : Text('Sort by ??? (High-Low)'),
                          ),
                          PopupMenuItem<String>(
                            value: 'sortPercentLow',
                            child: _sortBy == 'sortPercentLow'
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sort by % (Low-High)'),
                                      WidthBox(10.0),
                                      Icon(Icons.check_box_sharp,
                                          color: kSecondaryColor),
                                    ],
                                  )
                                : Text('Sort by ??? (Low-High)'),
                          ),
                          PopupMenuItem<String>(
                            value: 'sortPercentHigh',
                            child: _sortBy == 'sortPercentHigh'
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sort by % (High-Low'),
                                      WidthBox(10.0),
                                      Icon(Icons.check_box_sharp,
                                          color: kSecondaryColor),
                                    ],
                                  )
                                : Text('Sort by % (High-Low)'),
                          ),
                        ],
                        onSelected: (String value) => {
                          // setState(() {
                          //   this._sortBy = value;
                          //   getMarketDataInternal();
                          // })
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.marketData.length - 1,
                      itemBuilder: (BuildContext build, int i) {
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: ExpandablePanel(
                              header: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 30,
                                        width: 60,
                                        child: Image.asset(
                                          'assets/images/stock/${snapshot.data?.marketData[i + 1].symbol}.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      '???${snapshot.data?.marketData[i + 1].lastPrice}'
                                          .text
                                          .semiBold
                                          .make(),
                                    ],
                                  ),
                                  HeightBox(10.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: snapshot.data.marketData[i + 1]
                                            .companyName.text.ellipsis.bold
                                            .make(),
                                      ),
                                      snapshot.data.marketData[i + 1].change
                                              .toString()
                                              .contains('-')
                                          ? '${snapshot.data?.marketData[i + 1].change} (${snapshot.data?.marketData[i + 1].pChange}%)'
                                              .text
                                              .semiBold
                                              .red500
                                              .make()
                                          : '${snapshot.data?.marketData[i + 1].change} (${snapshot.data?.marketData[i + 1].pChange}%)'
                                              .text
                                              .semiBold
                                              .green500
                                              .make(),
                                    ],
                                  ),
                                ],
                              ),
                              expanded: Container(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BuySellScreen(
                                              buyOrSell: 'buy',
                                              marketData: snapshot
                                                  .data.marketData[i + 1],
                                            ),
                                          ),
                                        )
                                      },
                                      child: Text('BUY'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.greenAccent,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BuySellScreen(
                                              buyOrSell: 'sell',
                                              marketData: snapshot
                                                  .data.marketData[i + 1],
                                            ),
                                          ),
                                        )
                                      },
                                      child: Text('SELL'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.deepOrangeAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ).p8();
            },
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 0),
    );
  }
}
