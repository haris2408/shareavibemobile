import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code/components/helper_var.dart';

import '../components/loadingoverlay.dart';


class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0.05*height, 0, 0),

              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                        child: Image.asset('images/fulllogo.png')
                    ),
                    SizedBox(height: 0.05*height,),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "To Continue",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Center(
                      child: Container(
                        width: 0.8 * width,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCDCDC),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(50.0),
                            right: Radius.circular(50.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Image.asset(
                                'images/email_icon.png',
                                width: 30.0,
                                height: 30.0,
                                // color: Colors.white,
                              ),
                            ),
                            Expanded(
                                child: TextField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'email',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Center(
                      child: Container(
                        width: 0.8 * width,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCDCDC),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(50.0),
                            right: Radius.circular(50.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Image.asset(
                                'images/password_icon.png',
                                width: 30.0,
                                height: 30.0,
                                // color: Colors.white,
                              ),
                            ),
                            Expanded(
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'password',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    ElevatedButton(
                      onPressed: () async {
                        print("**********login pressed");
                        final email = this.emailController.text;
                        final password = this.passwordController.text;

                        if (email.isEmpty || password.isEmpty) {
                          print('Please fill in all the fields');
                          showDialog(context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  title: Text("Warning"),
                                  content: Text('Please fill in all the fields'),
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
                          return;
                        }

                        const url = '${baseurl}/api/login_mobile';
                        Map<String, String> body = {
                          'email': email,
                          'password': password,
                        };
                        setState((){
                          _loading = true;
                        });
                        final response = await http.post(Uri.parse(url), body: jsonEncode(body)).timeout(const Duration(seconds: 10));

                        setState((){
                          _loading = false;
                          this.passwordController.clear();
                          this.emailController.clear();
                        });
                        Map<String, dynamic> BODY = jsonDecode(response.body);
                        print(BODY);
                        if(BODY['status'] == 'success'){
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          try {
                            await prefs.setString('session_id', BODY['session_id']);
                            await prefs.setString('user', json.encode(BODY['user']));
                            // print(prefs.getString('session_id'));
                            // print(prefs.getString('user'));
                            Navigator.pushReplacementNamed(context,'/locationidentifier');
                          }
                          catch(e){
                            print("error in saving user details in shared pref");
                            print(e);
                          }
                        }
                        else{
                          showDialog(context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  title: Text("Login Failed"),
                                  content: Text('The email or password that you entered might be wrong.\nPlease try again!'),
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
                        minimumSize: Size(95.0, 30.0),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text(
                      "OR",
                      style: TextStyle(
                        fontSize: 9.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                      ),
                    ),

                    const SizedBox(height: 10,),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print("****************Google pressed");
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      title: Text("Message"),
                                      content: Text('Google sign in coming soon'),
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
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                              primary: Colors.white,
                            ),
                            child: Image.asset(
                              'images/G_icon.png',
                              width: 35,
                              height: 35,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10.0,),
                          ElevatedButton(
                            onPressed: () {
                              // Your button on press logic here
                              print("****************Facebook pressed");
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      title: Text("Message"),
                                      content: Text('Facebook sign in coming soon'),
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
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                              primary: Colors.white,
                            ),
                            child: Image.asset(
                              'images/F_icon.png',
                              width: 35,
                              height: 35,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ]
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 8.0,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            print("***************************Signup pressed");
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            "Signup",
                            style: TextStyle(
                              fontSize: 10.0,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0,),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'images/loginpage_bottomart.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading) LoadingOverlay(),
          ],
        )
      ),
    );
  }
}
