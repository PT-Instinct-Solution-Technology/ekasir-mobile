import 'package:flutter/material.dart';

class EasyAccess extends StatelessWidget {
  final String path;
  final Color color;
  final String text;

  EasyAccess({required this.path, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: color,
            borderRadius:
                BorderRadius.circular(10.0), // Sesuaikan nilai sesuai keinginan
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              path,
              width: 30,
              height: 30,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
