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
  final String jumlah;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.jenisMenu,
    required this.jumlah,
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
  List<Menu> keranjang = [];

  bool _isCashPayment = true;
  List<bool> _paymentMethodSelections = [true, false];

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
                  jumlah: '0',
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
                  jumlah: '0',
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
            indicatorColor: Colors.white,
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
                _showCart(context);
              },
              backgroundColor: Colors.orange,
              child: Icon(Icons.shopping_cart),
            ),
            if (keranjang.isNotEmpty)
              Positioned(
                right: 5,
                top: 5,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    '${keranjang.length}',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
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
          _showQuantityDialog(context, item);
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              'http://127.0.0.1:8000/storage/menu_images/${item.imageUrl}'),
          radius: 30,
        ),
        title: Text(item.name),
        subtitle: Text(item.description),
        trailing: Text(
          'Rp. ${item.price}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, Menu item) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Masukkan Jumlah Pesanan'),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      quantity = int.tryParse(value) ?? 1;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Pesanan',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
            ),
            TextButton(
              onPressed: () {
                _addToCart(context, item, quantity);
                Navigator.of(context).pop();
              },
              child: Text('Masukkan ke Keranjang',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(BuildContext context, Menu item, int quantity) {
    setState(() {
      keranjang.add(Menu(
          id: item.id,
          name: item.name,
          description: item.description,
          imageUrl: item.imageUrl,
          price: item.price,
          jenisMenu: item.jenisMenu,
          jumlah: quantity.toString()));
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$quantity ${item.name} ditambahkan ke keranjang.'),
      duration: Duration(seconds: 2),
    ));
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400.0,
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Keranjang',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: keranjang.length,
                  itemBuilder: (context, index) {
                    final item = keranjang[index];
                    return Card(
                      elevation: 2.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'http://127.0.0.1:8000/storage/menu_images/${item.imageUrl}'),
                        ),
                        title: Text(item.name),
                        subtitle: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rp.${item.price}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'Jumlah: ${item.jumlah}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Text('\$${item.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removeFromCart(context, index);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _paymentMenu(context);
                },
                child: const Text('Checkout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  primary: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _paymentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pembayaran',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Daftar Pesanan:',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: keranjang.length,
                      itemBuilder: (context, index) {
                        final item = keranjang[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rp.${item.price}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Jumlah: ${item.jumlah}',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'Total Harga: Rp.${_calculateTotalPrice()}',
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 20.0),
                  ToggleButtons(
                    selectedColor: Colors.orange,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.money),
                            SizedBox(width: 8),
                            Text('Cash'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.qr_code),
                            SizedBox(width: 8),
                            Text('QRIS'),
                          ],
                        ),
                      ),
                    ],
                    isSelected: _paymentMethodSelections,
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < _paymentMethodSelections.length;
                            buttonIndex++) {
                          if (buttonIndex == index) {
                            _paymentMethodSelections[buttonIndex] = true;
                          } else {
                            _paymentMethodSelections[buttonIndex] = false;
                          }
                        }
                        _isCashPayment =
                            index == 0; // Index 0 is for Cash, 1 is for QRIS
                      });
                    },
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_isCashPayment) {
                        // _placeOrder(context);
                      } else {
                        _confirmPayment(context);
                      }
                    },
                    child: Text(
                      _isCashPayment ? 'Pesan Sekarang' : 'Bayar Sekarang',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      primary: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Fungsi untuk menghitung total harga pesanan
  double _calculateTotalPrice() {
    double total = 0;
    for (var item in keranjang) {
      total += item.price * int.parse(item.jumlah);
    }
    return total;
  }

// Fungsi untuk mengkonfirmasi pembayaran
  void _confirmPayment(BuildContext context) {
    // Tambahkan logika untuk konfirmasi pembayaran, misalnya menampilkan pesan sukses dan menghapus keranjang
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pembayaran Berhasil'),
      duration: Duration(seconds: 2),
    ));
    // Kosongkan keranjang setelah pembayaran berhasil
    setState(() {
      keranjang.clear();
    });
    Navigator.of(context)
        .pop(); // Tutup bottom sheet setelah pembayaran berhasil
  }

  void _removeFromCart(BuildContext context, int index) {
    setState(() {
      keranjang.removeAt(index);
    });
  }
}
