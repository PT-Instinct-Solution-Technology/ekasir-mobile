import 'package:ekasir/admin/list_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../admin/dashboard_page.dart';

class MenuAdmin extends StatefulWidget {
  @override
  _MenuAdminState createState() => _MenuAdminState();
}

class _MenuAdminState extends State<MenuAdmin> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    ListMenuPage(),
    DashboardPage(),
    DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // final authState = Provider.of<AuthState>(context);
    // setState(() {
    //   _notificationCount = authState.notifCount;
    // });

    // print('ini auth ${authState.notifCount}');
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50.0,
        items: const <Widget>[
          Icon(
            Icons.home,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.restaurant_menu,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.shopping_cart,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: Colors.white,
          ),
        ],
        color: Colors.orange,
        buttonBackgroundColor: Colors.orange,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
