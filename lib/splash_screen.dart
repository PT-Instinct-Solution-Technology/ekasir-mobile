import 'package:flutter/material.dart';
import 'package:ekasir/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
      // _getPreference();
    });
  }

  Widget _buildIconWithText(path, Color backgroundColor, String text) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(
            path,
            width: 50,
            height: 50,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Background dengan efek buram
          Container(
            color: const Color.fromRGBO(5, 6, 8, 0.85),
          ),
          // Layer 2: Gambar 'bg.png' di atas latar belakang buram
          Center(
            child: Image.asset(
              'assets/img/bg.webp',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              color: const Color.fromRGBO(255, 255, 255,
                  0.2), // Ganti warna putih untuk efek buram sesuai keinginan
              colorBlendMode: BlendMode.dstATop,
            ),
          ),
          // Layer 3: Konten di atas gambar
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                    radius: (52),
                    backgroundColor: const Color.fromARGB(255, 176, 217, 219),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset("assets/img/logo.jpeg"),
                    )),
                const Text(
                  'Bebek',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const Text(
                  'Asli Madura Bintaro',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
