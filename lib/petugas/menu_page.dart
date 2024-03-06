import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Tambahkan import untuk http

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<dynamic> dataInformasi = [];
  bool loading = true;
  bool nullResponse = false;
  late String token;

  @override
  void initState() {
    super.initState();
    getTokenFromSharedPreferences();
  }

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token')!;
      });
      getDataKontens();
    }
    print('tps token: $token');
  }

  Future<void> getDataKontens() async {
    try {
      const String apiUrl = 'http://127.0.0.1:8000/api/auth/menus';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final length = responseData['data'].length;
        setState(() {
          loading = false;
          dataInformasi = responseData['data'];
          if (length != 0) {
            nullResponse = false;
          } else {
            nullResponse = true;
          }
        });
        print('test data Informasi: $dataInformasi');
      } else {
        setState(() {
          loading = false;
        });
        // Handle error response
        print('Failed to load data from the API $response');
        _showErrorDialog('Request Gagal',
            'Tidak dapat menampilkan data konten, silahkan dicoba kembali');
      }
    } catch (e) {
      // Handle exception
      print('Error Api: $e');
      setState(() {
        loading = false;
      });
      _showErrorDialog(
          'Masalah Koneksi', 'Periksa koneksi anda, lalu coba kembali');
    }
  }

  Future<void> _showErrorDialog(title, message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Menu Favorit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 16),
          if (dataInformasi.isNotEmpty)
            ...dataInformasi.map((info) => NewsCard(
                  nama_menu: info['nama_menu'],
                  deskripsi_menu: info['deskripsi_menu'],
                  harga: info['harga_menu'],
                  gambar_menu: info['gambar_menu'],
                ))
          else
            Text('Tidak ada informasi yang ditemukan'),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String nama_menu;
  final String deskripsi_menu;
  final String harga;
  final String gambar_menu;

  const NewsCard({
    required this.nama_menu,
    required this.deskripsi_menu,
    required this.harga,
    required this.gambar_menu,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar menu di sebelah kiri
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 100, // Sesuaikan dengan lebar gambar yang diinginkan
                child: Image.network(
                    'http://127.0.0.1:8000/storage/menu_images/$gambar_menu'), // Ganti dengan widget gambar yang sesuai
              ),
            ),
            // Informasi nama menu, deskripsi menu, dan harga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama_menu,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    deskripsi_menu,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Harga: $harga',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
