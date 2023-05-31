import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cafe.dart';


class CafeDialog extends StatelessWidget {
  final Cafe cafe;
  // final Function onYesPressed;
  final Function onNoPressed;


  CafeDialog({required this.cafe, required this.onNoPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: const Text('Are you sitting in this cafe?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120.0, // set fixed height for image
            width: 120.0, // set fixed width for image
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.network(
                "http://192.168.18.178:8000${cafe.logo}",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            cafe.name,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onNoPressed as void Function()?,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            primary: Colors.grey[300],
            onPrimary: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          ),
          child: const Text(
            'No',
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            try {
              await prefs.setString('cafe', jsonEncode(cafe.toMap()));
              Navigator.pushReplacementNamed(context, '/linkpusher');
            }
            catch(e){
              print("error in dialog yes pressed");
              print(e);
            }


          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            primary: const Color(0xFFFE9F24),
            onPrimary: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          ),
          child: const Text(
            'Yes',
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

}
