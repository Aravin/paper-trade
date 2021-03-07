import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paper_trade/models/market_data.dart';
import 'package:paper_trade/models/market_details.dart';
import 'package:paper_trade/providers/provider.dart';
import 'package:paper_trade/screens/buysell.dart';
import 'package:paper_trade/screens/login.dart';
import 'package:paper_trade/shared/firebase.dart';
import 'package:paper_trade/widgets/bottom_navigation_bar.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:expandable/expandable.dart';

final currency = NumberFormat.simpleCurrency(locale: 'en_IN');

class OrdersScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final AsyncValue<User> _authChange = watch(authStateChangesProvider);
    final AsyncValue<MarketDetails> userProvider = watch(marketDataProvider);

    double getCurrentPrice(String symbol) {
      if (userProvider?.data?.value?.marketData != null) {
        double lPrice = userProvider.data.value.marketData
            .firstWhere((q) => q.symbol == symbol)
            .lastPrice;

        return lPrice;
      }

      return 0;
    }

    double calculateProfitLoss(String symbol, int qty, double buyPrice) {
      if (userProvider?.data?.value?.marketData != null) {
        double lPrice = userProvider.data.value.marketData
            .firstWhere((q) => q.symbol == symbol)
            .lastPrice;

        return lPrice * qty;
      }

      return 0;
    }

    double calculateProfitLossPercent(String symbol, double buyPrice) {
      if (userProvider?.data?.value?.marketData != null) {
        double lPrice = userProvider.data.value.marketData
            .firstWhere((q) => q.symbol == symbol)
            .lastPrice;

        return 100 - (buyPrice / lPrice) * 100;
      }

      return 0;
    }

    MarketData getMarketDataBySymbol(String symbol) {
      return userProvider.data.value.marketData
          .firstWhere((q) => q.symbol == symbol);
    }

    return _authChange.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Oops, Failed to load login information.'),
      data: (user) => (user != null || user.uid != null)
          ? Scaffold(
              body: SafeArea(
                child: DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: TabBar(
                      tabs: [
                        Tab(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule),
                              WidthBox(7.5),
                              'Pending'.text.make()
                            ],
                          ),
                        ),
                        Tab(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.done_all),
                              WidthBox(7.5),
                              'Execeted'.text.make()
                            ],
                          ),
                        ),
                        Tab(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_done),
                              WidthBox(7.5),
                              'Cancelled'.text.make()
                            ],
                          ),
                        ),
                      ],
                    ),
                    body: TabBarView(
                      children: [
                        Container(
                          child: StreamBuilder<QuerySnapshot>(
                              stream: readOrders(
                                orderType: 'Pending',
                                uid: _authChange.data.value.uid,
                              ),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Something went wrong');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasData &&
                                    snapshot.data.size == 0) {
                                  return Center(
                                      child: Text('No Pending Orders...'));
                                }

                                return ListView(
                                  children: snapshot.data.docs
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data();

                                    return Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: ExpandablePanel(
                                          header: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    height: 30,
                                                    width: 60,
                                                    child: Image.asset(
                                                      'assets/images/stock/${data['symbol']}.png',
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                  'LTP: ${currency.format(getCurrentPrice(data['symbol']))}'
                                                      .text
                                                      .semiBold
                                                      .make(),
                                                ],
                                              ),
                                              HeightBox(10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child:
                                                        '${document.data()['symbol']}'
                                                            .text
                                                            .ellipsis
                                                            .bold
                                                            .make(),
                                                  ),
                                                  'Order Price: ${currency.format(data['buyPrice'])}'
                                                      .text
                                                      .semiBold
                                                      .make(),
                                                ],
                                              ),
                                            ],
                                          ),
                                          expanded: Container(
                                            padding: EdgeInsets.only(top: 20.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              BuySellScreen(
                                                            buyOrSell: document
                                                                    .data()[
                                                                'orderType'],
                                                            marketData:
                                                                getMarketDataBySymbol(
                                                                    document.data()[
                                                                        'symbol']),
                                                            docId: document.id,
                                                          ),
                                                        ),
                                                      )
                                                    },
                                                    child: Text('MODIFY'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary:
                                                          Colors.orangeAccent,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => {
                                                      cancelOrder(document.id),
                                                    },
                                                    child: Text('CANCEL'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: Colors.redAccent,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }),
                        ),
                        Container(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: readOrders(
                              orderType: 'Completed',
                              uid: _authChange.data.value.uid,
                            ),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasData && snapshot.data.size == 0) {
                                return Center(
                                    child: Text('No Executed Orders...'));
                              }

                              return ListView(
                                children: snapshot.data.docs.map(
                                  (DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data();

                                    return Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: 60,
                                                  child: Image.asset(
                                                    'assets/images/stock/${data['symbol']}.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                'LTP: ${currency.format(getCurrentPrice(data['symbol']))}'
                                                    .text
                                                    .semiBold
                                                    .make(),
                                              ],
                                            ),
                                            HeightBox(10.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child:
                                                      '${document.data()['symbol']}'
                                                          .text
                                                          .ellipsis
                                                          .bold
                                                          .make(),
                                                ),
                                                'Buy Price: ${currency.format(data['buyPrice'])}'
                                                    .text
                                                    .semiBold
                                                    .make(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              );
                            },
                          ),
                        ),
                        Container(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: readOrders(
                              orderType: 'Cancelled',
                              uid: _authChange.data.value.uid,
                            ),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasData && snapshot.data.size == 0) {
                                return Center(
                                    child: Text('No Cancelled Orders...'));
                              }

                              return ListView(
                                children: snapshot.data.docs.map(
                                  (DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data();

                                    return Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: 60,
                                                  child: Image.asset(
                                                    'assets/images/stock/${data['symbol']}.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                'LTP: ${currency.format(getCurrentPrice(data['symbol']))}'
                                                    .text
                                                    .semiBold
                                                    .make(),
                                              ],
                                            ),
                                            HeightBox(10.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                '${document.data()['symbol']}'
                                                    .text
                                                    .ellipsis
                                                    .bold
                                                    .make(),
                                                'Order Price: ${currency.format(data['buyPrice'])}'
                                                    .text
                                                    .semiBold
                                                    .make(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: AppBottomNavigationBar(currentIndex: 1),
            )
          : LoginScreen(),
    );
  }
}
