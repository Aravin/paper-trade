import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_trade/main.dart';
import 'package:paper_trade/screens/login.dart';
import 'package:paper_trade/shared/firebase.dart';
import 'package:paper_trade/widgets/bottom_navigation_bar.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

final currency = NumberFormat.simpleCurrency(locale: 'en_IN');

class AccountsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final AsyncValue<User> _authChange = watch(authStateChangesProvider);

    return _authChange.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Oops, Failed to load login information.'),
      data: (user) => (user != null || user.uid != null)
          ? Scaffold(
              body: SafeArea(
                child: FutureBuilder(
                    future: readAccount(uid: _authChange.data.value.uid),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text("Something went wrong");
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> data = snapshot.data.data();
                        print(data);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            'ACCOUNT'
                                .text
                                .xl
                                .extraBold
                                .underline
                                .widest
                                .green500
                                .make(),
                            HeightBox(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                'User ID'.text.lg.make(),
                                user.uid
                                    .substring(0, 8)
                                    .text
                                    .uppercase
                                    .lg
                                    .make(),
                              ],
                            ),
                            HeightBox(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                'Account Balance'.text.lg.make(),
                                '${currency.format(data['balance'])}'
                                    .text
                                    .lg
                                    .make(),
                              ],
                            ),
                            HeightBox(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                'Used Margin'.text.lg.make(),
                                '${currency.format(data['marginUsed'])}'
                                    .text
                                    .lg
                                    .make(),
                              ],
                            ),
                            HeightBox(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                'Available Margin'.text.lg.make(),
                                '${currency.format(data['availableMargin'])}'
                                    .text
                                    .lg
                                    .make(),
                              ],
                            ),
                            HeightBox(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RaisedButton(
                                    onPressed: () => {},
                                    child: Text('ADD FUND'),
                                    color: Colors.greenAccent),
                                RaisedButton(
                                  onPressed: () => {},
                                  child: Text('WITHDRAW FUND'),
                                  color: Colors.deepOrangeAccent,
                                ),
                              ],
                            ),
                            // Container(
                            //   child: Text(user.toString()),
                            // )
                          ],
                        ).p12();
                      }

                      return Center(child: CircularProgressIndicator());
                    }),
              ),
              bottomNavigationBar: AppBottomNavigationBar(currentIndex: 3),
            )
          : LoginScreen(),
    );
  }
}
