import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code/components/helper_var.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int _pushesAvailable = 10; // Example value for number of pushes available
  bool _freePushesAvailable = false; // Flag to show/hide free pushes available section
  bool _timerActive = false; // Flag to start/stop countdown timer
  int _remainingTime = 3600; // Countdown timer duration in seconds
  Timer? _timer; // Timer object to handle countdown timer
  late Map<String, dynamic> userdets;
  late Map<String, dynamic> cafe_dict;
  late String sesh_id;

  @override
  void initState() {
    super.initState();
    userdets = Map();
    userdets['name'] = 'test';
    if (_pushesAvailable == 0) {
      _freePushesAvailable = true;
      startTimer();
    }
    loadSharedPref();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timerActive = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _timerActive = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Drawer(
        width: 0.65 * width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(top: 40),
              height: 0.3 * height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/drawer_back.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children:  [
                  const CircleAvatar(
                    backgroundImage: AssetImage('images/user_profile_image.png'),
                    radius: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userdets['name'],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pushNamed(context, "/playlist");
                      },
                      style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFE9F24),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(50.0),
                      right: Radius.circular(50.0),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  minimumSize: Size(115.0, 30.0),
                      ),
                      child: const Text(
                        'Cafe Playlist',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Add your logic for "help" button here
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xFFFE9F24),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(50.0),
                              right: Radius.circular(50.0),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          minimumSize: Size(115.0, 30.0),
                      ),
                      child: const Text(
                        'Help',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Add your logic for "about" button here
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFFE9F24),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(50.0),
                            right: Radius.circular(50.0),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        minimumSize: Size(115.0, 30.0),
                      ),
                      child: const Text(
                        'About',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        const url = '${baseurl}/api/leave_cafe';
                        Map<String, dynamic> body = {
                          'session_id': sesh_id,
                          'email': userdets['email'],
                          'cafe_id': cafe_dict['id']
                        };
                        try{
                          final response = await http.post(Uri.parse(url), body: jsonEncode(body)).timeout(Duration(seconds: 10));
                          Map<String, dynamic> BODY = jsonDecode(response.body);
                          print(BODY);
                          if(BODY['status'] == 'success'){
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.remove('cafe');
                            Navigator.pushReplacementNamed(context, '/locationidentifier');
                          }
                        }
                        catch(e){
                          print(e);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        side: BorderSide(color: Color(0xFFFE9F24)),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(50.0),
                            right: Radius.circular(50.0),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        minimumSize: Size(115.0, 30.0),
                      ),
                      child: const Text(
                        'Leave Cafe',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     const url = '${baseurl}/api/logout_mobile';
                    //     Map<String, String> body = {
                    //       'session_id': userdets['session_id']
                    //     };
                    //     try{
                    //       final response = await http.post(Uri.parse(url), body: jsonEncode(body)).timeout(Duration(seconds: 10));
                    //       Map<String, dynamic> BODY = jsonDecode(response.body);
                    //       print(BODY);
                    //       if(BODY['status'] == 'success'){
                    //         SharedPreferences prefs = await SharedPreferences.getInstance();
                    //         prefs.clear();
                    //         Navigator.pushReplacementNamed(context, '/login');
                    //       }
                    //     }
                    //     catch(e){
                    //       print(e);
                    //     }
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors.white,
                    //     side: BorderSide(color: Color(0xFFFE9F24)),
                    //     shape: const RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.horizontal(
                    //         left: Radius.circular(50.0),
                    //         right: Radius.circular(50.0),
                    //       ),
                    //     ),
                    //     padding: EdgeInsets.symmetric(vertical: 10.0),
                    //     minimumSize: Size(115.0, 30.0),
                    //   ),
                    //   child: const Text(
                    //     'Logout',
                    //     style: TextStyle(
                    //       fontFamily: 'Poppins',
                    //       fontSize: 16.0,
                    //       fontWeight: FontWeight.w800,
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      print("in loadSharedPref cafe side panel");
      // Value found in shared preferences
      setState((){
        cafe_dict = jsonDecode(cafe.toString());
        print(cafe_dict);
        print(cafe_dict.runtimeType);
        userdets = jsonDecode(user);
        print(userdets.toString());

        sesh_id = session_id;
        print(session_id);
        print(session_id.runtimeType);
      });

    } else {
      // Value not found
      print('Value not found in shared preferences');
    }
  }


}
