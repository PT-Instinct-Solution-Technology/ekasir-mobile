import 'dart:convert';
import 'package:ekasir/admin/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ekasir/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TpsPage extends StatefulWidget {
  @override
  _TpsPageState createState() => _TpsPageState();
}

class _TpsPageState extends State<TpsPage> {
  List<Map<String, String>> tpsData = [];
  List<Map<String, String>> filteredTpsData = [];
  TextEditingController searchController = TextEditingController();
  String? token;
  bool loading = true;
  bool nullResponse = false;

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
      fetchDataFromApi();
    }
    print('tps token: $token');
  }

  Future<void> fetchDataFromApi() async {
    try {
      // const String apiUrl = 'http://localhost:8000/api/auth/list-tps';
      const String apiUrl = 'http://127.0.0.1:8000/api/auth/menus';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        final length = responseData['data'].length;

        tpsData = List<Map<String, String>>.from(
          data.map((dynamic item) {
            return {
              'id': item['id'].toString(),
              'namaTps': item['nama'].toString(),
              'kabupaten': item['kota'].toString(),
              'kecamatan': item['kecamatan'].toString(),
              'desa': item['desa'].toString(),
              'status': item['status'].toString(),
            };
          }),
        );

        setState(() {
          loading = false;
          filteredTpsData = tpsData;
          if (length != 0) {
            nullResponse = false;
          } else {
            nullResponse = true;
          }
        });
        print('test tps data: $data');
      } else {
        // Handle error response
        _showErrorDialog('Request Gagal', 'Gagal menampilkan data TPS');
        setState(() {
          loading = false;
        });
        print('Failed to load data from the API');
      }
    } catch (e) {
      // Handle exception
      _showErrorDialog(
          'Koneksi Gagal', 'Ada masalah dengan koneksi internet anda');
      setState(() {
        loading = false;
      });
      print('Error Api: $e');
    }
  }

  void filterTpsData(String query) {
    List<Map<String, String>> filteredList = tpsData.where((tps) {
      String namaTps = tps['namaTps']!.toLowerCase();
      String kabupaten = tps['kabupaten']!.toLowerCase();
      String kecamatan = tps['kecamatan']!.toLowerCase();
      String desa = tps['desa']!.toLowerCase();

      return namaTps.contains(query.toLowerCase()) ||
          kabupaten.contains(query.toLowerCase()) ||
          kecamatan.contains(query.toLowerCase()) ||
          desa.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredTpsData = filteredList;
    });
  }

  Widget buildTpsCard(
    String namaTps,
    String kabupaten,
    String kecamatan,
    String desa,
    String id,
    String status,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.blue,
      elevation: 4.0,
      child: ListTile(
        title: Text(
          'TPS: $namaTps',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kabupaten: $kabupaten',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              'Kecamatan: $kecamatan',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              'Desa: $desa',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            status == '0' ? Icons.arrow_forward : Icons.verified_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            status == '0'
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(),
                    ),
                  )
                : null;
          },
        ),
      ),
    );
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
    final authState = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
                radius: (20),
                backgroundColor: const Color.fromARGB(255, 176, 217, 219),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset("assets/img/bg.jpg"),
                )),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'TPS',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: const TextStyle(color: Colors.white),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    filteredTpsData = tpsData;
                                  });
                                },
                              )
                            : const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                        filled: true,
                        fillColor: Colors.blue,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      controller: searchController,
                      onChanged: (value) {
                        filterTpsData(value);
                      },
                    ),
                  ),
                  SizedBox(
                      width: 8), // Jarak antara search box dan tombol "Tambah"
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            loading
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
                : nullResponse
                    ? const Expanded(
                        child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum ada data TPS',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: filteredTpsData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return buildTpsCard(
                              filteredTpsData[index]['namaTps']!,
                              filteredTpsData[index]['kabupaten']!,
                              filteredTpsData[index]['kecamatan']!,
                              filteredTpsData[index]['desa']!,
                              filteredTpsData[index]['id']!,
                              filteredTpsData[index]['status']!,
                              context,
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
