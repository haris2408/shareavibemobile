
import 'package:code/pages/linkpush.dart';
import 'package:code/pages/playlist.dart';
import 'package:code/pages/songs.dart';
import 'package:code/pages/startloadingscreen.dart';
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/location_identify.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const StartLoading(),
    routes: {
      '/signup': (context) =>  Signup(),
      '/login': (context) =>  Login(),
      '/linkpusher': (context) => const LinkPush(),
      '/playlist': (context) => const PlaylistPage(),
      '/songs': (context) => const SongPage(),
      '/locationidentifier': (context) => const LocationIdentify(),
    },
    onGenerateRoute: (RouteSettings settings) {
      if (settings.name == '/signup') {
        return MaterialPageRoute(builder: (context) => Signup());
      }
      if (settings.name == '/playlist') {
        return MaterialPageRoute(builder: (context) => PlaylistPage());
      }
      if (settings.name == '/songs') {
        return MaterialPageRoute(builder: (context) => SongPage());
      }
      if (settings.name == '/login') {
        return MaterialPageRoute(builder: (context) => Login());
      }
      if (settings.name == '/linkpusher') {
        return MaterialPageRoute(builder: (context) => LinkPush());
      }
      if (settings.name == '/locationidentifier') {
        return MaterialPageRoute(builder: (context) => LocationIdentify());
      }


      return null;
    },
  ));
}

