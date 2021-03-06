import 'package:flutter/material.dart';
import 'package:paper_trade/screens/Portfolio.dart';
import 'package:paper_trade/screens/accounts.dart';
import 'package:paper_trade/screens/home.dart';
import 'package:paper_trade/screens/orders.dart';
import 'package:paper_trade/shared/constants.dart';

class AppBottomNavigationBar extends StatefulWidget {
  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState();

  final int currentIndex;
  AppBottomNavigationBar({this.currentIndex});
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    print([index, _selectedIndex]);
    if (widget.currentIndex == index) {
      return;
    }
    Widget page;
    if (index == 0) {
      page = HomeScreen();
    }
    if (index == 1) {
      page = OrdersScreen();
    }
    if (index == 2) {
      page = PortfolioScreen();
    }
    if (index == 3) {
      page = AccountsScreen();
    }

    setState(() {
      _selectedIndex = widget.currentIndex;

      if (page == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      }

      // Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_center),
          label: 'Portfolio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          label: 'Account',
        ),
      ],
      currentIndex: widget.currentIndex,
      backgroundColor: kPrimaryColor,
      selectedItemColor: Colors.white,
      onTap: _onItemTapped,
    );
  }
}
