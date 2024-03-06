import 'package:ekasir/admin/input_menu.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum JenisMenu { Makanan, Minuman }

class Menu {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String jenisMenu;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.jenisMenu,
  });
}

class ListMenuPage extends StatefulWidget {
  @override
  _ListMenuPageState createState() => _ListMenuPageState();
}

class _ListMenuPageState extends State<ListMenuPage> {
  String? token;
  List<Menu> makanan = [];
  List<Menu> minuman = [];

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token');
      });
      fetchData();
    }
    print('tps token: $token');
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/auth/menus'),
      headers: {
        'Authorization': 'Bearer $token',
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      setState(() {
        makanan = data
            .where((menu) => menu['jenis_menu'] == '0')
            .map<Menu>((menu) => Menu(
                  id: menu['id'].toString(),
                  name: menu['nama_menu'].toString(),
                  description: menu['deskripsi_menu'].toString(),
                  imageUrl: menu['gambar_menu'].toString(),
                  price: double.parse(menu['harga_menu'].toString()),
                  jenisMenu: menu['jenis_menu'].toString(),
                ))
            .toList();

        minuman = data
            .where((menu) => menu['jenis_menu'] == '1')
            .map<Menu>((menu) => Menu(
                  id: menu['id'].toString(),
                  name: menu['nama_menu'].toString(),
                  description: menu['deskripsi_menu'].toString(),
                  imageUrl: menu['gambar_menu'].toString(),
                  price: double.parse(menu['harga_menu'].toString()),
                  jenisMenu: menu['jenis_menu'].toString(),
                ))
            .toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    getTokenFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Jumlah tab
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text('Daftar Menu'),
          bottom: const TabBar(
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: 'Makanan'),
              Tab(text: 'Minuman'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMenuList(context, makanan),
            _buildMenuList(context, minuman),
          ],
        ),
        floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputMenuPage(),
                  ),
                );
              },
              backgroundColor: Colors.orange,
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, List<Menu> menu) {
    return ListView.builder(
      itemCount: menu.length,
      itemBuilder: (context, index) {
        return _buildMenuTile(context, menu[index]);
      },
    );
  }

  Widget _buildMenuTile(BuildContext context, Menu item) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
          _showConfirmationDialog(context, item);
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              'http://127.0.0.1:8000/storage/menu_images/${item.imageUrl}'),
          radius: 30,
        ),
        title: Text(item.name),
        subtitle: Text(item.description),
        trailing: Text(
          'Rp. ${item.price.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, Menu item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Hapus ${item.name} dari menu?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Oke'),
            ),
          ],
        );
      },
    );
  }
}
