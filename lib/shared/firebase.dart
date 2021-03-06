// Import the firebase_core and cloud_firestore plugin

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final CollectionReference orders =
    FirebaseFirestore.instance.collection('orders');
final CollectionReference accounts =
    FirebaseFirestore.instance.collection('accounts');

Future<void> createOrder(
  String symbol,
  num marketPrice,
  int orderQty,
  String orderType,
  String uid,
  String docId,
) {
  if (docId != null) {
    return orders.doc(docId).update({
      'symbol': symbol,
      'buyPrice': marketPrice,
      'orderQty': orderQty,
      'modifiedOn': DateTime.now(),
      'orderType': orderType,
      'status': orderType == 'Market' ? 'Completed' : 'Completed', // 'Pending',
      'uid': uid,
    }).then((value) {
      print("Order Placed");
      accounts.doc(uid).get().then((data) => {
            accounts.doc(uid).update({
              'balance': data['balance'] - marketPrice * orderQty,
              'marginUsed': marketPrice * orderQty,
              'availableMargin': data['balance'] - marketPrice * orderQty,
            })
          });
    }).catchError((error) => print("Failed to place order: $error"));
  }
  return orders.add({
    'symbol': symbol,
    'buyPrice': marketPrice,
    'orderQty': orderQty,
    'timestamp': DateTime.now(),
    'orderType': orderType,
    'status': orderType == 'Market' ? 'Completed' : 'Pending',
    'uid': uid,
  }).then((value) {
    print("Order Placed");
    accounts.doc(uid).get().then((data) => {
          accounts.doc(uid).update({
            'balance': data['balance'] - marketPrice * orderQty,
            'marginUsed': marketPrice * orderQty,
            'availableMargin': data['balance'] - marketPrice * orderQty,
          })
        });
  }).catchError((error) => print("Failed to place order: $error"));
}

Stream<QuerySnapshot> readOrders({String orderType, String uid}) {
  return orders
      .where('uid', isEqualTo: uid)
      .where('status', isEqualTo: orderType)
      .snapshots();
}

Future<DocumentSnapshot> readOrder(orderId) {
  return orders.doc(orderId).get();
}

Future<void> cancelOrder(
  String docId,
) {
  return orders
      .doc(docId)
      .update({
        'cancelledOn': DateTime.now(),
        'status': 'Cancelled',
      })
      .then((value) {})
      .catchError((error) => print("Failed to place order: $error"));
}

// accounts
Future<void> createAccount(
  User user,
) {
  return accounts
      .doc(user.uid)
      .set({
        'email': user.email,
        'isAnonymous': user.isAnonymous,
        'createdTimestamp': DateTime.now(),
        'balance': 100000.00,
        'availableMargin': 100000.00,
        'usedMargin': 0.00
      })
      .then((value) => print("Account Created"))
      .catchError((error) => print("Failed to Create Account: $error"));
}

Future<DocumentSnapshot> readAccount({String uid}) {
  return accounts.doc(uid).get();
}
