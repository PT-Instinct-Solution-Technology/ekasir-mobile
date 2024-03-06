import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:ekasir/admin/menu.dart';
import 'package:ekasir/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputMenuPage extends StatefulWidget {
  @override
  _InputMenuPageState createState() => _InputMenuPageState();
}

class _InputMenuPageState extends State<InputMenuPage> {
  TextEditingController namaMakananController = TextEditingController();
  TextEditingController hargaMakananController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? file = 'null';
  String? token;
  var picked;
  bool loading = false;
  String selectedJenisMenu = '0'; // Default jenis menu makanan

  @override
  void initState() {
    super.initState();
    getTokenFromSharedPreferences();
  }

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token');
      });
    }
    print('tps token: $token');
  }

  Future<void> sendDataKonten(userId) async {
    try {
      String filePath = picked.files.first.path.toString();
      File file = File(filePath);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/auth/menus'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      // Baca tipe file
      String fileType = file.path.split('.').last;

      // Periksa tipe file dan tambahkan ke request sesuai tipe
      if (fileType == 'mp4' || fileType == 'mov') {
        // File adalah video
        request.files.add(http.MultipartFile(
          'gambar', // Simpan dalam field 'gambar' agar sesuai dengan server
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ));
      } else {
        // File adalah gambar
        request.files.add(http.MultipartFile(
          'gambar_menu', // Simpan dalam field 'gambar' agar sesuai dengan server
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ));
      }

      request.fields['nama_menu'] = namaMakananController.text.toString();
      request.fields['harga_menu'] = hargaMakananController.text.toString();
      request.fields['deskripsi_menu'] = descriptionController.text.toString();
      request.fields['jenis_menu'] = selectedJenisMenu;
      // request.fields['userId'] = userId.toString();

      var response = await request.send();
      if (response.statusCode == 200) {
        print('test input: $response');
        _showDialog('Request Berhasil', 'Konten berhasil dikirim');
        setState(() {
          loading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuAdmin(),
          ),
        );
      } else {
        setState(() {
          loading = false;
        });
        _showDialog('Request Gagal', 'Gagal upload konten');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loading = false;
      });
      _showDialog('Network Error', 'Periksa koneksi anda, lalu coba kembali');
    }
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Tambah Menu',
          style: TextStyle(fontSize: 20),
        ),
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input Gambar Konten
                  file == 'null'
                      ? SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                picked = await FilePicker.platform.pickFiles();

                                if (picked != null && picked.files.isNotEmpty) {
                                  setState(() {
                                    file = picked.files.first.name.toString();
                                  });
                                  print(
                                      'File yang diunggah: ${picked.files.first.name}');
                                } else {
                                  // Pemilihan file dibatalkan.
                                }
                              } catch (e) {
                                // Terjadi kesalahan: $e
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text('Gambar Menu'),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.file_present,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Gambar: $file',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                  const SizedBox(height: 16.0),

                  // Input Nama Makanan
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: namaMakananController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Menu',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Dropdown Jenis Menu
                  DropdownButtonFormField<String>(
                    value: selectedJenisMenu,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedJenisMenu = newValue!;
                      });
                    },
                    items: <String>['0', '1'].map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value == '0' ? 'Makanan' : 'Minuman',
                          ),
                        );
                      },
                    ).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Jenis Menu',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Input Harga Makanan
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: hargaMakananController,
                    decoration: const InputDecoration(
                      labelText: 'Harga Menu',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Input Deskripsi
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Menu',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Button Submit
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        loading = true;
                      });
                      sendDataKonten(authState.userId);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      primary: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }
}
