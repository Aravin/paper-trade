import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_trade/models/market_details.dart';
import 'package:paper_trade/shared/getMarketData.dart';

// market data
final marketDataProvider =
    StreamProvider<MarketDetails>((ref) => getMarketDataApp());

// firebase setup
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// account status change
final authStateChangesProvider = StreamProvider<User>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());
