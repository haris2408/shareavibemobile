import 'dart:convert';
import 'package:code/components/currently_playing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_icons/flutter_icons.dart';

import '../components/cafe_screen_drawer.dart';
import '../models/cafe.dart';

class LinkPush extends StatefulWidget {
  const LinkPush({Key? key}) : super(key: key);

  @override
  State<LinkPush> createState() => _LinkPushState();
}

class _LinkPushState extends State<LinkPush> {
  final TextEditingController linkController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Cafe currCafe = Cafe(
    id: "test",
    name: "test",
    isActive: false,
    currToken: 0,
    nextToken: 0,
    logo: "test",
  );
  String tokenValue = "-";
  String linkText = '';
  String session_id = '';
  dynamic userdets;

  @override
  void initState() {
    loadCafe();
    super.initState();
  }

  Future<void> loadToken() async{
    try {
      const url = 'http://192.168.18.178:8000/api/get_user_token';

      Map<String, String> body = {
        'session_id': session_id,
        'email': userdets['email'],
        'cafe_id': this.currCafe.id
      };
      final response = await http.post(Uri.parse(url), body: jsonEncode(body));
      print('************************inside loadToken');

      if (response.statusCode == 200) {
        // API request was successful
        print(response.statusCode);
        dynamic apiResult = json.decode(response.body); // Assuming the API response is JSON
        print(apiResult);
        if(apiResult['status'] == 'success') {
          setState(() {
            this.tokenValue = apiResult['body']['token_num'].toString();
          });
        }
        else{

        }
      } else {
        // Handle API request error
        print('Error: ${response.statusCode}');
      }
    }
    catch(e){
      print('error in loadToken');
      print(e);
    }
  }

  Future<void> loadCafe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('cafe');
    String? sessionid = prefs.getString('session_id');
    print(jsonString);
    print(sessionid);
    if (jsonString != null) {
      setState(() {
        currCafe = Cafe.fromMap(jsonDecode(jsonString));
        userdets = json.decode(prefs.getString('user').toString());
        this.session_id = sessionid.toString();
        print("Cafe loaded");
        print(currCafe.name);
        loadToken();
      });
    }
    else{
      Navigator.pop(context);
    }
  }
  Future<void> _refreshData() async {
    await loadCafe();

    // Additional refresh logic if needed
  }

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/link_push_background.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(3, 45, 0, 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: Image.asset(
                                  'images/drawer_icon.png',
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _scaffoldKey.currentState!.openDrawer();
                                },
                              ),
                            ),
                            Image.network(
                              "http://192.168.18.178:8000${currCafe.logo}",
                              height: 100,
                              width: 100,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Welcome to ${currCafe.name}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF333232),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'images/token_background.png',
                            width: 200,
                            height: 100,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Token no.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                tokenValue,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: width * 0.8,
                      decoration: BoxDecoration(
                        color: Color(0xFFDEDEDE),
                        borderRadius: BorderRadius.circular(60.0),
                      ),
                      child: TextField(
                        controller: this.linkController,
                        onChanged: (value) {
                          setState(() {
                            linkText = value;
                          });
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 12, 12, 20),
                          labelText: 'Paste link here',
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        print("**********push link pressed");
                        print(linkText);
                        this.linkText = linkController.text.trim();
                        Map<String, String> body = {
                          'youtube_link': this.linkText,
                          'cafe_id': this.currCafe.id,
                          'session_id': this.session_id
                        };
                        final response = await http.post(Uri.parse('http://192.168.18.178:8000/api/add_to_queue_mobile'), body: jsonEncode(body ));
                        if(response.statusCode == 200){
                          // print(response.body.runtimeType);
                          Map<String, dynamic> BODY = jsonDecode(response.body);
                          linkController.clear();
                          showDialog(context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  title: Text("Congratulations!!!"),
                                  content: Text('Your link has been pushed'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
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
                                        'ok',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                          setState(() {
                            this.tokenValue = BODY["token"].toString();
                          });
                        }
                        else{
                          showDialog(context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  title: Text("Warning"),
                                  content: Text('Error Occured!\n Please Try again!'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
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
                                        'ok',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        }

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
                        'Push',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'images/yt_logo.png',
                          ),
                          iconSize: (1/3)*(width*0.45),
                          onPressed: () {
                            print("*************youtube pressed");
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                            'images/spotify_logo.png',
                          ),
                          iconSize: (1/3)*(width*0.45),
                          onPressed: () {
                            print("*************spotify pressed");
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                            'images/sc_logo.png',
                          ),
                          iconSize: (1/3)*(width*0.45),
                          onPressed: () {
                            print("*************soundcloud pressed");
                          },
                        ),
                      ],
                    ),
                  ],
                )
              ),
            ),
            currentPlaying(),
          ],
        ),
      ),
    );
  }
}
