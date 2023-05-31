import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:code/components/cafe_dialog.dart';
import 'package:code/components/error_dialog.dart';
import 'package:code/components/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../components/fetch_location_inquiry.dart';
import '../components/loadingoverlay.dart';
import '../models/cafe.dart';

class LocationIdentify extends StatefulWidget {
  const LocationIdentify({Key? key}) : super(key: key);

  @override
  State<LocationIdentify> createState() => _LocationIdentifyState();
}

class _LocationIdentifyState extends State<LocationIdentify> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late double lat;
  late double long;
  late String message = "press button to fetch location";
  late Position _position = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 2, heading: 0, speed: 0, speedAccuracy: 0);
  bool _loading = false;
  late Map<String,dynamic> _response = {'not_inti':true};
  List<Cafe> cafes = [];
  int currIdx = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 1));

      showDialog(
          context: context,
          builder: (BuildContext context){
            return FetchLocationInquiry(
                onYesPressed: ()async{
                  Navigator.of(context).pop();

                  get_cafes();


                  print("**********FetchLocationInquiry pressed");
                }
            );
          }
      );
    });

  }



  Future<void> _requestPermissions() async {
    final List<Permission> permissions = [
      Permission.location,
      Permission.storage,
    ];

    Map<Permission, PermissionStatus> results = await permissions.request();

    // check if both permissions are granted
    if (results[Permission.location] == PermissionStatus.granted &&
        results[Permission.storage] == PermissionStatus.granted) {
      // print('Both permissions granted.');
    } else {
      // print('Permissions not granted.');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future<void> _hit_api(double lat,double long) async{
    try{
      final URI = Uri.parse("http://192.168.18.178:8000/getcafes/${lat}/${long}");
      // print(URI);
      final response = await http.get(URI).timeout(Duration(seconds: 10));
      // // print(response.body);
      _response = jsonDecode(response.body);
      // // print(_response);
    }
    on TimeoutException catch (_) {
      return;
    } catch (e) {
      return;
    }

  }

  Future<void> get_cafes() async{
    await _requestPermissions();

    setState(() {
      _loading = true;
    });

    // await Future.delayed(Duration(seconds: 5));

    // await _determinePosition().then((value) => {
    //     // print("*********lat : ${value.latitude}");
    //     // print("*********long : ${value.longitude}");
    // });
    await _determinePosition().then((value) {
      // print("*********lat : ${value.latitude}");
      // print("*********long : ${value.longitude}");
      setState(() {
        lat = value.latitude;
        long = value.longitude;
        message = '${value.latitude} + ${value.longitude}';
        _position = value;
      });
    });

    await _hit_api(lat, long);

    setState(() {
      _loading = false;
    });
    // print(_response);

    if(_response['status'] == 'failure'){
      display_error_dialog_box();
    }
    else{
      load_cafe_choices();
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Color(0xFFFE9F24),
            elevation: 0, //remove drop shadow from appbar
            leading: IconButton(
              icon: Image.asset(
                'images/drawer_icon.png',
                color: Colors.white,
              ),
              onPressed: () {
                //TODO: Implement side drawer
                _scaffoldKey.currentState!.openDrawer();
              },
            ),
          ),
          drawer: MyDrawer(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/loc_s_back.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Find Your Place',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25,),
              Container(
                width: 0.6*screenWidth,
                child: ElevatedButton(
                  onPressed: () async {
                    get_cafes();

                    // print("**********fetch location pressed");

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
                    minimumSize: Size(95.0, 50.0),
                  ),
                  child: const Text(
                    'Fetch Location',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                ),
              )
            ],
          ),
        ),
        if (_loading) LoadingOverlay(),
        if (cafes.length > 0 && currIdx < cafes.length) CafeDialog(
            cafe: cafes[currIdx],
            onNoPressed: (){
              setState(() {
                currIdx++;
              });
            }
        ),
        if(currIdx >= cafes.length && cafes.length != 0) ErrorDialog(
            message: "Please Try Again",
            okayFunction: (){
              setState(() {
                cafes.clear();
                currIdx = 0;
              });
            },
            tryAgainFunction: (){
              setState(() {
                cafes.clear();
                currIdx = 0;
              });
            },
        ),
      ],
    );
  }

  void display_error_dialog_box() {
    showDialog(
      context: context,
      builder: (BuildContext context){
        return ErrorDialog(
          message: "Error encountered!!\nPlease try again",
          okayFunction: (){
            Navigator.of(context).pop();
          },
          tryAgainFunction: (){
            Navigator.of(context).pop();

            get_cafes();


            // print("**********Try Again pressed");
          },
        );
      }
    );
  }

  void load_cafe_choices() {
    if(_response['status'] == 'success') {

      setState(() {
        print(_response['cafes']);
        // for(var cafe in _response['cafes']){
        //   // print(cafe);
        //   // print(cafe['id'].toString().runtimeType);
        //   // print(cafe['name'].runtimeType);
        //   // print(cafe['is_active'].runtimeType);
        //   // print(cafe['current_token'].runtimeType);
        //   // print(cafe['next_token'].runtimeType);
        //   // print(cafe['logo'].toString().runtimeType);
        // }
        cafes = List<Cafe>.from(_response['cafes'].map((cafe) =>
            Cafe(
              id: cafe['id'].toString(),
              name: cafe['name'],
              isActive: cafe['is_active'],
              currToken: cafe['current_token'],
              nextToken: cafe['next_token'],
              logo: cafe['logo'],
            )));
      });
    }

  }
}
