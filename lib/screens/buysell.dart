import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_trade/models/market_data.dart';
import 'package:paper_trade/providers/provider.dart';
import 'package:paper_trade/screens/orders.dart';
import 'package:paper_trade/shared/constants.dart';
import 'package:paper_trade/shared/firebase.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderTypeState extends StateNotifier<String> {
  OrderTypeState() : super('Market');

  void change(String text) => state = text;
}

final _orderProvider = StateNotifierProvider((ref) => OrderTypeState());

class BuySellScreen extends ConsumerWidget {
  BuySellScreen({this.buyOrSell, this.marketData, this.docId});

  final String buyOrSell;
  final MarketData marketData;
  final String docId;

  final _formKey = GlobalKey<FormState>();

  // void initState() {
  //   super.initState();
  //   _qtyController = TextEditingController(text: '1');
  //   _priceController = TextEditingController(
  //       text: this.this.marketData.lastPrice.toString());
  // }

  // void dispose() {
  //   _qtyController.dispose();
  //   _priceController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    TextEditingController _qtyController = TextEditingController(text: '1');
    TextEditingController _priceController =
        TextEditingController(text: this.marketData.lastPrice.toString());

    final AsyncValue<User> _authChange = watch(authStateChangesProvider);
    String _orderType = watch(_orderProvider.state);

    return Scaffold(
      appBar: AppBar(
        title: 'Place Order'.text.make(),
        backgroundColor:
            this.buyOrSell == 'sell' ? Colors.redAccent : Colors.greenAccent,
      ),
      body: Container(
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 30,
                        width: 60,
                        child: Image.asset(
                          'assets/images/stock/${this.marketData.symbol}.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      '₹${this.marketData.lastPrice}'.text.semiBold.make(),
                    ],
                  ),
                  HeightBox(10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: this
                            .marketData
                            .companyName
                            .text
                            .ellipsis
                            .bold
                            .make(),
                      ),
                      this.marketData.change.toString().contains('-')
                          ? '${this.marketData.change} (${this.marketData.pChange}%)'
                              .text
                              .semiBold
                              .red500
                              .make()
                          : '${this.marketData.change} (${this.marketData.pChange}%)'
                              .text
                              .semiBold
                              .green500
                              .make(),
                    ],
                  ),
                  HeightBox(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 9,
                        child: 'Order Type'.text.make(),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButton<String>(
                          value: _orderType,
                          icon: Icon(Icons.arrow_downward),
                          hint: Text('Order Type'),
                          iconSize: 16,
                          // elevation: 16,
                          style: TextStyle(color: Colors.grey[900]),
                          underline: Container(
                            height: 2,
                            color: kPrimaryColor,
                          ),
                          onChanged: (String newValue) {
                            // _orderType = newValue;
                            context.read(_orderProvider).change(newValue);
                          },
                          items: <String>['Market', 'Limit']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  HeightBox(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 9,
                        child: 'Market Price'.text.make(),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _priceController,
                          textInputAction: TextInputAction.go,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Price',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          enabled: watch(_orderProvider.state) == 'Limit',
                          validator: (value) {
                            if (value.isEmpty ||
                                double.tryParse(value) == null) {
                              return 'Invalid Price';
                            }
                            if (double.tryParse(value) <=
                                (this.marketData.lastPrice / 100) * 80) {
                              return 'Min ${((this.marketData.lastPrice / 100) * 80).toStringAsFixed(2)}';
                            }
                            if (double.tryParse(value) >=
                                (this.marketData.lastPrice / 100) * 120) {
                              return 'Max ${((this.marketData.lastPrice / 100) * 120).toStringAsFixed(2)}';
                            }
                            return null;
                          },
                          onChanged: (String value) {
                            if (_formKey.currentState.validate()) {
                              // setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  HeightBox(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 9,
                        child: 'Order Quantity'.text.make(),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _qtyController,
                          textInputAction: TextInputAction.go,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Quantity',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value.isEmpty || int.tryParse(value) == null) {
                              return 'Invalid Qty';
                            }
                            if (int.tryParse(value) <= 0) {
                              return 'Min 1';
                            }
                            if (int.tryParse(value) >= 10000) {
                              return 'Max 10000';
                            }
                            return null;
                          },
                          onChanged: (String value) {
                            if (_formKey.currentState.validate()) {
                              // setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  HeightBox(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => {
                            createOrder(
                              this.marketData.symbol,
                              _orderType == 'Market'
                                  ? this.marketData.lastPrice
                                  : double.parse(_priceController.value.text),
                              int.parse(_qtyController.value.text),
                              _orderType,
                              _authChange.data.value.uid,
                              docId,
                            ).then((data) => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrdersScreen(),
                                    ),
                                  )
                                }),
                          },
                          child: Text('CONFIRM ORDER'),
                          style: ElevatedButton.styleFrom(
                            primary: this.buyOrSell == 'sell'
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            HeightBox(20),
            'Performance'.text.gray700.bold.xl.make(),
            HeightBox(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                this.marketData.dayLow.text.make(),
                this.marketData.dayHigh.text.make(),
              ],
            ),
            Slider(
              onChanged: (double value) {},
              min: this.marketData.dayLow,
              value: this.marketData.lastPrice,
              max: this.marketData.dayHigh,
              label: this.marketData.lastPrice.toString(),
            ),
            HeightBox(5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                this.marketData.yearLow.text.make(),
                this.marketData.yearHigh.text.make(),
              ],
            ),
            Slider(
              onChanged: (double value) {},
              min: this.marketData.yearLow,
              value: this.marketData.lastPrice,
              max: this.marketData.yearHigh,
              label: this.marketData.lastPrice.toString(),
            ),
            HeightBox(10),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: this.marketData.open.toString().text.make(),
                      subtitle: 'Open Price'.text.make(),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title:
                          this.marketData.previousClose.toString().text.make(),
                      subtitle: 'Previous Close'.text.make(),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: '${this.marketData.perChange30d}%'.text.make(),
                      subtitle: 'Monthly Return'.text.make(),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: '${this.marketData.perChange365d}%'.text.make(),
                      subtitle: 'Yearly Return'.text.make(),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: this
                          .marketData
                          .totalTradedValue
                          .toString()
                          .text
                          .make(),
                      subtitle: 'Total Traded Value'.text.make(),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: this
                          .marketData
                          .totalTradedVolume
                          .toStringAsFixed(0)
                          .text
                          .make(),
                      subtitle: 'Total Traded Volume'.text.make(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).p8(),
    );
  }
}
