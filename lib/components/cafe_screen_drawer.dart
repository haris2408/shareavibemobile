import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    if (_pushesAvailable == 0) {
      _freePushesAvailable = true;
      startTimer();
    }
    loadUser();
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
                        const url = 'http://192.168.18.178:8000/api/logout_mobile';
                        Map<String, String> body = {
                          'session_id': userdets['session_id']
                        };
                        try{
                          final response = await http.post(Uri.parse(url), body: jsonEncode(body)).timeout(Duration(seconds: 10));
                          Map<String, dynamic> BODY = jsonDecode(response.body);
                          print(BODY);
                          if(BODY['status'] == 'success'){
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            Navigator.pushReplacementNamed(context, '/login');
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
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('user')){
      return null;
    }
    dynamic usersss = prefs.getString('user');
    setState((){
      userdets = json.decode(usersss);
    });
  }
}
