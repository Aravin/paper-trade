import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:paper_trade/providers/provider.dart';
import 'package:paper_trade/screens/home.dart';
import 'package:paper_trade/shared/firebase.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final FirebaseAuth _firebaseAuth = watch(firebaseAuthProvider);
    final AsyncValue<User> _authChange = watch(authStateChangesProvider);

    return _authChange.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) =>
          const Text('Oops, Failed to load login information.'),
      data: (user) => (user == null || user.uid == null)
          ? Scaffold(
              body: SafeArea(
                  child: Container(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HeightBox(10),
                      Container(
                        width: 200,
                        child: Image.asset(
                          'assets/images/stock.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        child: Text(_authChange.data.toString()),
                      ),
                      HeightBox(50),
                      SignInButton(
                        Buttons.GoogleDark,
                        onPressed: () async {
                          // Trigger the authentication flow
                          final GoogleSignInAccount googleUser =
                              await GoogleSignIn().signIn();

                          // Obtain the auth details from the request
                          final GoogleSignInAuthentication googleAuth =
                              await googleUser.authentication;

                          // Create a new credential
                          final GoogleAuthCredential credential =
                              GoogleAuthProvider.credential(
                            accessToken: googleAuth.accessToken,
                            idToken: googleAuth.idToken,
                          );
                          _firebaseAuth
                              .signInWithCredential(credential)
                              .then((data) => {createAccount(data.user)});
                        },
                      ),
                      SignInButtonBuilder(
                        text: 'Anonymous sign-in',
                        icon: Icons.privacy_tip,
                        onPressed: () {
                          _firebaseAuth
                              .signInAnonymously()
                              .then((data) => {createAccount(data.user)});
                          ;
                        },
                        backgroundColor: Colors.blueGrey[700],
                      )
                    ],
                  ),
                ),
              )),
            )
          : HomeScreen(),
    );
  }
}
