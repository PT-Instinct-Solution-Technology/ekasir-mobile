import 'package:flutter/material.dart';

class TahapanPemiluPage extends StatelessWidget {
  final List<String> images = [
    'assets/img/tahapan/satu.png',
    'assets/img/tahapan/dua.png',
    'assets/img/tahapan/tiga.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tahapan Pemilu'),
        backgroundColor: const Color.fromRGBO(25, 25, 25, 1),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: images.map((image) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.asset(
                image,
                height: 408,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
