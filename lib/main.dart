import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_trade/models/market_details.dart';
import 'package:paper_trade/screens/login.dart';
import 'package:paper_trade/shared/constants.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paper_trade/shared/getMarketData.dart';

final marketDataProvider =
    StreamProvider<MarketDetails>((ref) => getMarketDataApp().asStream());

// 1
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// 2
final authStateChangesProvider = StreamProvider<User>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: Main(),
    ),
  );
}

class Main extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper Trade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // backgroundColor: Colors.white,
        // scaffoldBackgroundColor: Colors.white,
        cardTheme: CardTheme(elevation: 2.5),
        dividerTheme: DividerThemeData(color: kPrimaryColor, thickness: 1.0),
        primarySwatch: Colors.green,
        primaryColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
            // bodyText2: TextStyle(fontSize: 18.0),
            ),
        sliderTheme: SliderTheme.of(context).copyWith(
          showValueIndicator: ShowValueIndicator.always,
          valueIndicatorShape: PaddleSliderValueIndicatorShape(),
          valueIndicatorTextStyle: TextStyle(
            color: Colors.black,
          ),
          activeTrackColor: Colors.grey,
          inactiveTrackColor: Colors.grey,
        ),
      ),
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return LoginScreen();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
