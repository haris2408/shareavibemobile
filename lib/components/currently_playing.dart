import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'my_flutter_app_icons.dart';

class currentPlaying extends StatefulWidget {
  const currentPlaying({Key? key}) : super(key: key);

  @override
  State<currentPlaying> createState() => _currentPlayingState();
}

class _currentPlayingState extends State<currentPlaying> {
  bool isLiked = false;
  bool isdisLiked  = false;
  Map<String, dynamic> apiResult = Map();
  Map<String, dynamic> cafe_dict = Map();
  Map<String, dynamic> user_dict = Map();
  String sesh_id = '';
  String curr_token = '####';
  String curr_song_name = "looooooooooooooooong";


  @override
  void initState() {
    super.initState();
    loadSharedPref();
    // Start the timer when the widget is initialized

    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      fetchData(); // Make the API request every 2 minutes
    });
  }

  Future<String?> getValueFromSharedPreferences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  void loadSharedPref() async{
    String? cafe = await getValueFromSharedPreferences('cafe');
    String? user = await getValueFromSharedPreferences('user');
    String? session_id = await getValueFromSharedPreferences('session_id');
    if (cafe != null && user != null && session_id != null) {
      print("in loadSharedPref currently playing");
      // Value found in shared preferences
      cafe_dict = jsonDecode(cafe.toString());
      print(cafe_dict);
      print(cafe_dict.runtimeType);
      user_dict = jsonDecode(user);
      print(user_dict.toString());
      print(user_dict.runtimeType);
      sesh_id = session_id;
      print(session_id);
      print(session_id.runtimeType);
      await fetchData();
    } else {
      // Value not found
      print('Value not found in shared preferences');
    }
  }


  Future<void> fetchData() async {
    try {

      // Perform your API request here
      String url = 'http://192.168.18.178:8000/api/get_current_playing_song';
      print(url);
      Map<String, dynamic> body = {
        'session_id': sesh_id,
        'email': user_dict['email'],
        'cafe_id': cafe_dict['id']
      };
      final response = await http.post(Uri.parse(url), body:jsonEncode(body));

      if (response.statusCode == 200) {
        // API request was successful
        setState(() {
          print(response.statusCode);
          apiResult = json.decode(response.body); // Assuming the API response is JSON
          print(apiResult);
          setState(() {
            this.curr_token = apiResult['body']['curr_token'].toString();
            this.curr_song_name = apiResult['body']['song_name'];
          });
        });
      } else {
        // Handle API request error
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any other errors that occur during the request
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
        height: 60,
        width: width,
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey,
                    width: 0.5,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                this.curr_token,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333232),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    this.curr_song_name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333232),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                MyFlutterApp.heart_broken,
                color: isLiked ? Colors.red : null,
              ),
              onPressed: () {
                if (!isdisLiked) {
                  setState(() {
                    isLiked = !isLiked;
                  });
                } else {
                  setState(() {
                    isdisLiked = !isdisLiked;
                    isLiked = !isLiked;
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.favorite, // Custom broken heart icon
                color: isdisLiked ? Colors.red : null,
              ),
              onPressed: () {
                if (!isLiked) {
                  setState(() {
                    isdisLiked = !isdisLiked;
                  });
                } else {
                  setState(() {
                    isdisLiked = !isdisLiked;
                    isLiked = !isLiked;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
