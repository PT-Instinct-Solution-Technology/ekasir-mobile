import 'dart:convert';

import 'package:ekasir/petugas/makanan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ekasir/components/easy_access.dart';
import 'package:ekasir/petugas/menu_page.dart';
import 'package:ekasir/petugas/video.dart';
import 'package:ekasir/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../components/carousel.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime dateTime = DateTime.now();
  int tabIndex = 0;
  bool show = false;
  List<dynamic> dataInformasi = [];
  String? token;
  bool loading = true;
  bool nullResponse = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 20),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // card
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YourVideoContainer(
                      videoUrl: 'video.mp4',
                    ),
                  ),
                );
              },
              child: Container(
                height: 200,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Colors.orange, Colors.red],
                    stops: [0.2, 0.8],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Text(
                        'Selamat ${dateTime.hour >= 1 && dateTime.hour <= 9 ? 'Pagi' : dateTime.hour > 9 && dateTime.hour < 15 ? 'Siang' : dateTime.hour >= 15 && dateTime.hour <= 19 ? 'Sore' : 'Malam'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        // You can add an icon or image here
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.namaUser ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Pelanggan',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Warung Bebek',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Pelanggan #123',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // slider
            CarouselSection(),

            const SizedBox(
              height: 15,
            ),
            MenuPage(),
            // Bagian 2:
          ],
        ),
      ),
    );
  }
}
