import 'package:ekasir/petugas/makanan_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../petugas/dashboard_page.dart';

// ignore: must_be_immutable
class MenuPetugas extends StatefulWidget {
  int selectedIndex = 0;
  MenuPetugas({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _MenuPetugasState createState() => _MenuPetugasState();
}

class _MenuPetugasState extends State<MenuPetugas> {
  final List<Widget> _pages = [
    DashboardPage(),
    ListMenuPage(),
    ListMenuPage(),
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
      body: _pages[widget.selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: widget.selectedIndex,
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
            Icons.account_circle,
            size: 30,
            color: Colors.white,
          ),
        ],
        color: Colors.orange,
        buttonBackgroundColor: Colors.orange,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            widget.selectedIndex = index;
          });
        },
      ),
    );
  }
}
