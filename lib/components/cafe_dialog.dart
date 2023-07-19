import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code/components/helper_var.dart';
import '../models/cafe.dart';


class CafeDialog extends StatelessWidget {
  final Cafe cafe;
  late Map<String, dynamic> userdets;
  late String sesh_id;
  // final Function onYesPressed;
  final Function onNoPressed;
  Future<String?> getValueFromSharedPreferences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  Future<void> loadSharedPref() async{
    String? user = await getValueFromSharedPreferences('user');
    String? session_id = await getValueFromSharedPreferences('session_id');
    if (user != null && session_id != null) {
      print("in loadSharedPref cafe dialog box");
      // Value found in shared preferences
      userdets = jsonDecode(user);
      print(userdets.toString());

      sesh_id = session_id;
      print(session_id);
      print(session_id.runtimeType);
    } else {
      // Value not found
      print('Value not found in shared preferences');
    }
  }

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
                "${baseurl}${cafe.logo}",
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
              await loadSharedPref();
              await prefs.setString('cafe', jsonEncode(cafe.toMap()));
              if(await addtoCafe(sesh_id, cafe.id, userdets['email']))
              {
                Navigator.pushReplacementNamed(context, '/linkpusher');
              }
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

  Future<bool> addtoCafe(String session_id, String cafe_if, String email) async {
    const url = '${baseurl}/api/set_user_cafe_mobile';
    Map<String, String> body = {
      'session_id': session_id,
      'email': email,
      'cafe_id': cafe_if
    };
    try{
      final response = await http.post(Uri.parse(url), body: jsonEncode(body)).timeout(Duration(seconds: 10));
      Map<String, dynamic> BODY = jsonDecode(response.body);
      print(BODY);
      if(BODY['status'] == 'success'){
        return true;
      }
    }
    catch(e){
      print("error in addtoCfae");
      print(e);
      return false;
    }
    return false;
  }


}
