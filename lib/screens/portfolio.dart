import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paper_trade/models/market_details.dart';
import 'package:paper_trade/providers/provider.dart';
import 'package:paper_trade/screens/login.dart';
import 'package:paper_trade/shared/firebase.dart';
import 'package:paper_trade/widgets/bottom_navigation_bar.dart';
import 'package:velocity_x/velocity_x.dart';

final currency = NumberFormat.simpleCurrency(locale: 'en_IN');

class PortfolioScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final AsyncValue<User> _authChange = watch(authStateChangesProvider);
    final AsyncValue<MarketDetails> userProvider = watch(marketDataProvider);

    String getCurrentPrice(String symbol) {
      if (userProvider?.data?.value?.marketData != null) {
        double lPrice = userProvider.data.value.marketData
            .firstWhere((q) => q.symbol == symbol)
            .lastPrice;

        return currency.format(lPrice);
      }

      return currency.format(0);
    }

    String calculateProfitLoss(String symbol, int qty, double buyPrice) {
      if (userProvider?.data?.value?.marketData != null) {
        double lPrice = userProvider.data.value.marketData
            .firstWhere((q) => q.symbol == symbol)
            .lastPrice;

        return currency.format(lPrice * qty);
      }

      return currency.format(0);
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

    return _authChange.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Oops, Failed to load login information.'),
      data: (user) => (user != null || user.uid != null)
          ? Scaffold(
              body: SafeArea(
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: TabBar(
                      tabs: [
                        Tab(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hourglass_top),
                              WidthBox(7.5),
                              'Position'.text.make()
                            ],
                          ),
                        ),
                        Tab(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home),
                              WidthBox(7.5),
                              'Holding'.text.make()
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
                                    child: Text('No Active Position...'));
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
                                                'LTP: ${getCurrentPrice(data['symbol'])}'
                                                    .text
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
                                                '${currency.format(data['buyPrice'])} (${data['orderQty']} Qty)'
                                                    .text
                                                    .make(),
                                              ],
                                            ),
                                            HeightBox(10.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                'Invested: ${calculateProfitLoss(document.data()['symbol'], document.data()['orderQty'], document.data()['buyPrice'])}'
                                                    .text
                                                    .make(),
                                                'Value: ${calculateProfitLoss(document.data()['symbol'], document.data()['orderQty'], document.data()['buyPrice'])}'
                                                    .text
                                                    .make(),
                                              ],
                                            ),
                                            // HeightBox(10.0),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment
                                            //           .spaceBetween,
                                            //   children: [
                                            //     '-'.toString().contains('-')
                                            //         ? '1D: ${currency.format(4500)} (-10%)'
                                            //             .text
                                            //             .semiBold
                                            //             .red500
                                            //             .make()
                                            //         : '1D: ${currency.format(4500)} (-10%)'
                                            //             .text
                                            //             .semiBold
                                            //             .green500
                                            //             .make(),
                                            //     '+'.toString().contains('-')
                                            //         ? 'Total: ${currency.format(4500)} (+1%)'
                                            //             .text
                                            //             .semiBold
                                            //             .red500
                                            //             .make()
                                            //         : 'Total: ${currency.format(4500)} (+1%)'
                                            //             .text
                                            //             .semiBold
                                            //             .green500
                                            //             .make(),
                                            //   ],
                                            // ),
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
                                    child: Text('No Active Position...'));
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
                                                'LTP: ${getCurrentPrice(data['symbol'])}'
                                                    .text
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
                                                '${currency.format(data['buyPrice'])} (${data['orderQty']} Qty)'
                                                    .text
                                                    .make(),
                                              ],
                                            ),
                                            HeightBox(10.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                'Invested: ${calculateProfitLoss(document.data()['symbol'], document.data()['orderQty'], document.data()['buyPrice'])}'
                                                    .text
                                                    .make(),
                                                'Value: ${calculateProfitLoss(document.data()['symbol'], document.data()['orderQty'], document.data()['buyPrice'])}'
                                                    .text
                                                    .make(),
                                              ],
                                            ),
                                            // HeightBox(10.0),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment
                                            //           .spaceBetween,
                                            //   children: [
                                            //     '-'.toString().contains('-')
                                            //         ? '1D: ${currency.format(4500)} (-10%)'
                                            //             .text
                                            //             .semiBold
                                            //             .red500
                                            //             .make()
                                            //         : '1D: ${currency.format(4500)} (-10%)'
                                            //             .text
                                            //             .semiBold
                                            //             .green500
                                            //             .make(),
                                            //     '+'.toString().contains('-')
                                            //         ? 'Total: ${currency.format(4500)} (+1%)'
                                            //             .text
                                            //             .semiBold
                                            //             .red500
                                            //             .make()
                                            //         : 'Total: ${currency.format(4500)} (+1%)'
                                            //             .text
                                            //             .semiBold
                                            //             .green500
                                            //             .make(),
                                            //   ],
                                            // ),
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
              bottomNavigationBar: AppBottomNavigationBar(currentIndex: 2),
            )
          : LoginScreen(),
    );
  }
}
