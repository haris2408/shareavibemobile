import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cafe.dart';
import 'package:http/http.dart' as http;
import 'package:code/components/helper_var.dart';


class PlaylistPage extends StatefulWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late Cafe currCafe = Cafe(
    id: "test",
    name: "test",
    isActive: false,
    currToken: 0,
    nextToken: 0,
    logo: "test",
  );

  bool isLoading = false;
  List<dynamic> playlists = [];

  @override
  void initState() {
    super.initState();
    loadCafe();
  }

  Future<List<dynamic>> fetchPlaylists(String cafeId) async {
    final response = await http.get(Uri.parse('${baseurl}/api/get_playlist/$cafeId'));
    // print("***************************"+cafeId);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      final status = jsonResponse['status'];
      // print(jsonResponse['playlists']);
      if (status == 'success') {
        return jsonResponse['playlists'];
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load playlists');
    }
  }


  Future<void> loadCafe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('cafe');
    if (jsonString != null) {
      setState(() {
        isLoading = true;
      });
      currCafe = Cafe.fromMap(jsonDecode(jsonString));
      print("Cafe loaded");
      print(currCafe.name);

      // Fetch playlists when the cafe is loaded
      await fetchPlaylists(currCafe.id).then((fetchedPlaylists) {
        setState(() {
          print(fetchedPlaylists);
          playlists = fetchedPlaylists;
          isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        print('Error: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE9F24),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : playlists.isEmpty
          ? const Center(child: Text("This cafe currently has no playlist"))
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Playlists',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (BuildContext context, int index) {
                final playlist = playlists[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(
                      playlist['playlist_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    onTap: () {
                      // Handle the playlist item click
                      // Add your logic here
                      Navigator.pushNamed(context, "/songs", arguments: playlist);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
