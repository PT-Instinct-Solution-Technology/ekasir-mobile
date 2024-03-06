import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ekasir/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KomenAdmin extends StatefulWidget {
  final String kontenId;

  KomenAdmin({Key? key, required this.kontenId}) : super(key: key);

  @override
  _KomenAdminState createState() => _KomenAdminState();
}

class _KomenAdminState extends State<KomenAdmin> {
  TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> komensData = [];
  String? token;
  bool loading = true;

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
      fetchKomenByIdKonten();
    }
    print('tps token: $token');
  }

  Future<void> fetchKomenByIdKonten() async {
    try {
      String apiUrl =
          // 'http://localhost:8000/api/auth/list-komen-konten/${widget.kontenId}';
          'https://aaa.surabayawebtech.com/api/auth/list-komen-konten/${widget.kontenId}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          loading = false;
          komensData = List<Map<String, dynamic>>.from(responseData['data']);
        });
        print('response: ${responseData['data']}');
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan error sesuai kebutuhan
    }
  }

  Future<void> sendKomen(userId) async {
    try {
      String apiUrl =
          // 'http://localhost:8000/api/auth/komen-konten/${widget.kontenId}';
          'https://aaa.surabayawebtech.com/api/auth/komen-konten/${widget.kontenId}';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'komen': _commentController.text, 'userId': userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        _commentController.clear;
        fetchKomenByIdKonten();
        final responseData = json.decode(response.body);
        print('response: $responseData');
      } else {
        setState(() {
          loading = false;
        });
        _showErrorDialog('Pengiriman Gagal',
            'Komentar anda tidak terkirim, silahkan coba kembali');
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Error Koneksi',
          'Komentar tidak terkirim, periksa koneksi internet anda');
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

  Future<void> deleteComment(String commentId) async {
    try {
      String apiUrl =
          'https://aaa.surabayawebtech.com/api/auth/delete-komen/$commentId';

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Komentar berhasil dihapus
        fetchKomenByIdKonten();
        _showErrorDialog('Berhasil', 'Komentar berhasil dihapus');
        print('Komentar berhasil dihapus');
      } else {
        // Gagal menghapus komentar
        print('Gagal menghapus komentar. HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan error sesuai kebutuhan
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: loading
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
          : SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // Input Komentar
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Tambahkan komentar...',
                              hintStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.blue,
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Tombol Kirim Komentar
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_commentController.text.isNotEmpty) {
                                setState(() {
                                  loading = true;
                                });
                                sendKomen(authState.userId.toString());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromRGBO(77, 109, 96, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(loading ? 'loading...' : 'Kirim'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Komentar
                    const Text(
                      'Komentar:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    // Daftar Komentar
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: komensData.length,
                        itemBuilder: (context, index) {
                          final komen = komensData[index];
                          return buildComment(
                            komen['id'].toString(),
                            komen['nama_user'].toString(),
                            komen['komen'].toString(),
                            komen['created_at'].toString(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildComment(
      String id, String namaUser, String comment, String createdAt) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$namaUser',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                createdAt.substring(0, 10),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Tombol Hapus Komentar
          IconButton(
            onPressed: () {
              // Panggil fungsi untuk menghapus komentar dengan ID tertentu
              deleteComment(id);
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
