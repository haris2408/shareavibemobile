import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartLoading extends StatefulWidget {
  const StartLoading({Key? key}) : super(key: key);

  @override
  State<StartLoading> createState() => _StartLoadingState();
}

class _StartLoadingState extends State<StartLoading> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    // Simulate an asynchronous delay for demonstration purposes
    await Future.delayed(Duration(seconds: 2));

    // Get user_details and cafe details from shared preference
    final userDetails = await getUserDetailsFromSharedPreference();
    final cafeDetails = await getCafeDetailsFromSharedPreference();
    print(userDetails);
    print(cafeDetails);

    if (userDetails == null) {
      // User details not present, redirect to login page
      await clearSharedPreference();
      Navigator.pushReplacementNamed(context, '/login');
    }
    else {
      // Verify session ID through an API
      final sessionIdVerified = await verifySessionId(userDetails['session_id']);

      if (sessionIdVerified) {
        if (cafeDetails == null) {
          // User details present but cafe details not present, redirect to locationIdentify screen
          Navigator.pushReplacementNamed(context, '/locationidentifier');
        }
        else {
          // Both user_details and cafe details present, verify session and move to linkPush screen
          final sessionVerified = await verifySession("userDetails.sessionId", "cafeDetails.cafeId");
          if (sessionVerified) {
            Navigator.pushReplacementNamed(context, '/linkpusher');
          } else {
            // Session not verified, redirect to login screen and clear shared preference
            await clearSharedPreference();
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      }
      else {
        // Session not verified, redirect to login screen and clear shared preference
        await clearSharedPreference();
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<dynamic> getUserDetailsFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('user')){
      return null;
    }
    dynamic userdets = prefs.getString('user');

    return json.decode(userdets);
  }

  Future<dynamic> getCafeDetailsFromSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('cafe')){
      return null;
    }
    dynamic cafedets = prefs.getString('cafe');

    return json.decode(cafedets);
  }

  Future<bool> verifySessionId(String sessionId) async {
    const url = 'http://192.168.18.178:8000/api/verify_session_mobile';
    Map<String, String> body = {
      'session_id': sessionId
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
      print(e);
      return false;
    }
    return false;
  }

  Future<bool> verifySession(String sessionId, String cafeId) async {
    return true;
  }

  Future<void> clearSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/start_screen.png'),
              fit: BoxFit.fitHeight
            )
          ),
        ),
      ),
    );
  }
}
