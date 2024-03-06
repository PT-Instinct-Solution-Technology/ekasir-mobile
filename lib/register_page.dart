import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ekasir/login_page.dart';
import 'package:ekasir/petugas/menu.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  DateTime dateTime = DateTime.now();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  bool checkedValue = false;
  bool loading = false;

  Future<void> _register() async {
    final nama = _namaController.text;
    final email = _emailController.text;
    final noHp = _noTeleponController.text;
    try {
      final response = await http.post(
        // Uri.parse('http://localhost:8000/api/auth/register'),
        Uri.parse('https://aaa.surabayawebtech.com/api/auth/register'),

        body: {
          'nama': nama,
          'email': email,
          'no_hp': noHp,
        },
      );

      print(nama);
      print(email);
      print(noHp);
      if (response.statusCode == 201) {
        setState(() {
          loading = false;
        });
        final responseData = json.decode(response.body);
        print('berhasil: $responseData');
        await _showDialog('Register Berhasil',
            'Registrasi berhasil, silahkan cek email untuk aktivasi akun');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else {
        setState(() {
          loading = false;
        });
        _showDialog(
            'Register Gagal', 'Registrasi gagal, silahkan dicoba kembali');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('error: $e');
      _showDialog(
          'Register Gagal', 'Registrasi gagal, silahkan cek koneksi anda');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showDialog(title, message) async {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            color: const Color.fromRGBO(5, 6, 8, 0.85),
          ),
          Center(
            child: Image.asset(
              'assets/img/bg.jpg',
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
                    backgroundColor: Color.fromARGB(255, 176, 217, 219),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset("assets/img/logo.jpeg"),
                    )),
                SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 5,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "REGISTER",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 40),
                        // Form login
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            controller: _namaController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Nama',
                              labelStyle: TextStyle(color: Colors.black),
                              prefixIcon: Icon(Icons.person),
                              filled: true, // Memberi latar belakang pada input
                              fillColor: Colors
                                  .white, // Mengatur warna latar belakang input menjadi putih
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              prefixIcon: Icon(Icons.mail),
                              filled: true, // Memberi latar belakang pada input
                              fillColor: Colors
                                  .white, // Mengatur warna latar belakang input menjadi putih
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            controller: _noTeleponController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'No. Telepon',
                              labelStyle: TextStyle(color: Colors.black),
                              prefixIcon: Icon(Icons.phone),
                              filled: true, // Memberi latar belakang pada input
                              fillColor: Colors
                                  .white, // Mengatur warna latar belakang input menjadi putih
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              if (_namaController.text.isNotEmpty &&
                                  _noTeleponController.text.isNotEmpty) {
                                _register();
                              } else {
                                _showDialog('Data Tidak Lengkap',
                                    'Harap isi semua inputan sebelum mendaftar');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              primary: Color.fromRGBO(77, 109, 96, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(loading ? 'loading...' : 'Register'),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sudah punya akun?",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              child: const Text(" login",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                const Text(
                  'Bebek Asli Madura Bintaro',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
