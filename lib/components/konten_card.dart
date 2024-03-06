import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ekasir/admin/menu.dart';
import 'package:ekasir/components/komen_admin.dart';
import 'package:ekasir/petugas/dashboard_page.dart';
import 'package:ekasir/components/komen_petugas.dart';
import 'package:ekasir/petugas/menu.dart';
import 'package:ekasir/petugas/video.dart';
import 'package:ekasir/states/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentCard extends StatefulWidget {
  final String userId;
  final String id;
  final String imageUrl;
  final String caption;
  final String deskripsi;
  final int likes;
  final int dislikes;
  final int comments;
  final String tanggal;

  const ContentCard({
    required this.userId,
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.deskripsi,
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.tanggal,
  });

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  late String token;
  late bool loading;
  bool isLikeContent = false;
  Color colors = Colors.blue;

  @override
  void initState() {
    super.initState();
    loading = false;
    getTokenFromSharedPreferences();
  }

  Future<void> getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      setState(() {
        token = prefs.getString('token')!;
      });
    }
    isLike();
  }

  // void refresh() {
  //   KontenPage kontenPageInstance = KontenPage();
  //   kontenPageInstance.getDataKonten();
  // }

  Future<void> sendLike(String level) async {
    try {
      String apiUrl =
          'https://aaa.surabayawebtech.com/api/auth/reaksi-konten/${widget.id}';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': widget.userId, 'reaksi': '1'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        level == '0'
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuPetugas(
                    selectedIndex: 1,
                  ),
                ),
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuAdmin(),
                ),
              );
      } else {
        setState(() {
          loading = false;
        });
        _showErrorDialog(
            'Gagal', 'Gagal tidak menyukai konten, silahkan coba kembali');
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Error Koneksi',
          'Gagal tidak menyukai konten, periksa koneksi internet anda');
    }
  }

  Future<void> isLike() async {
    try {
      final response = await http.post(
        Uri.parse('https://aaa.surabayawebtech.com/api/auth/islike'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'userId': widget.userId.toString(),
          'kontenId': widget.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          setState(() {
            isLikeContent = true;
          });
        }
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }

  void _KonfirmasiDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  colors = Colors.blue;
                });
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                deleteContent(widget.id);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteContent(String contenId) async {
    try {
      String apiUrl =
          'https://aaa.surabayawebtech.com/api/auth/delete-konten/$contenId';

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _showErrorDialog('Berhasil', 'Konten berhasil dihapus');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuAdmin(),
          ),
        );
        print('Konten berhasil dihapus');
      } else {
        // Gagal menghapus Konten
        print('Gagal menghapus Konten. HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Tambahkan penanganan error sesuai kebutuhan
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return authState.levelUser == '1'
        ? Card(
            color: colors,
            margin: const EdgeInsets.all(16.0),
            elevation: 5.0,
            child: InkWell(
              onLongPress: () {
                setState(() {
                  colors = Colors.red;
                });

                _KonfirmasiDialog('Konfirmasi',
                    'Apakah anda yakin mau menghapus konten ${widget.caption}?');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tampilkan gambar jika bukan video
                      Visibility(
                        visible:
                            !widget.imageUrl.toLowerCase().endsWith('.mp4'),
                        child: Image.network(
                          'https://aaa.surabayawebtech.com/storage/konten/${widget.imageUrl}',
                          width: double.infinity,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Tampilkan tombol play jika video
                      Visibility(
                        visible: widget.imageUrl.toLowerCase().endsWith('.mp4'),
                        child: Positioned.fill(
                          child: Center(
                            child: InkWell(
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Putar video',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => YourVideoContainer(
                                      videoUrl: widget.imageUrl,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.caption,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.deskripsi,
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.tanggal,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),

                  // Jumlah Like dan Komen
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.favorite,
                                color:
                                    isLikeContent ? Colors.red : Colors.white,
                              ),
                              onTap: () {
                                if (!loading) {
                                  setState(() {
                                    loading = true;
                                  });
                                  sendLike(authState.levelUser.toString());
                                }
                              },
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Likes: ${widget.likes}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              child: const Icon(
                                Icons.comment,
                                color: Colors.white,
                              ),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  builder: (BuildContext context) {
                                    return authState.levelUser == '0'
                                        ? KomenPetugas(kontenId: widget.id)
                                        : KomenAdmin(kontenId: widget.id);
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Comments: ${widget.comments}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        : Card(
            color: colors,
            margin: const EdgeInsets.all(16.0),
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tampilkan gambar jika bukan video
                    Visibility(
                      visible: !widget.imageUrl.toLowerCase().endsWith('.mp4'),
                      child: Image.network(
                        'https://aaa.surabayawebtech.com/storage/konten/${widget.imageUrl}',
                        width: double.infinity,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Tampilkan tombol play jika video
                    Visibility(
                      visible: widget.imageUrl.toLowerCase().endsWith('.mp4'),
                      child: Positioned.fill(
                        child: Center(
                          child: InkWell(
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Putar video',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => YourVideoContainer(
                                    videoUrl: widget.imageUrl,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.caption,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.deskripsi,
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.tanggal,
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),

                // Jumlah Like dan Komen
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            child: Icon(
                              Icons.favorite,
                              color: isLikeContent ? Colors.red : Colors.white,
                            ),
                            onTap: () {
                              if (!loading) {
                                setState(() {
                                  loading = true;
                                });
                                sendLike(authState.levelUser.toString());
                              }
                            },
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Likes: ${widget.likes}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            child: const Icon(
                              Icons.comment,
                              color: Colors.white,
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                builder: (BuildContext context) {
                                  return authState.levelUser == '0'
                                      ? KomenPetugas(kontenId: widget.id)
                                      : KomenAdmin(kontenId: widget.id);
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Comments: ${widget.comments}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
