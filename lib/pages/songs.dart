import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cafe.dart';
import 'package:http/http.dart' as http;


class SongPage extends StatefulWidget {
  const SongPage({Key? key}) : super(key: key);

  @override
  State<SongPage> createState() => _SongPageState();
}

  class _SongPageState extends State<SongPage> {
  late Cafe currCafe = Cafe(
    id: "test",
    name: "test",
    isActive: false,
    currToken: 0,
    nextToken: 0,
    logo: "test",
  );


  bool isLoading = false;
  List<dynamic> Songs = [];
  late dynamic playlist = {};
  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> fetchSongs(String cafeId) async {
    final response = await http.get(Uri.parse('http://192.168.18.178:8000/api/get_songs/$cafeId'));
    // print("***************************"+cafeId);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      final status = jsonResponse['status'];
      // print(jsonResponse['Songs']);
      if (status == 'success') {
        return jsonResponse['songs'];
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load Songs');
    }
  }


  Future<void> loadPlaylist() async {
    setState(() {
      isLoading = true;
    });
    // final dynamic playlist = ModalRoute.of(context)!.settings.arguments;
    if(!playlist.isEmpty){
      print("*****************here");
      print(playlist);
      // Fetch Songs when the cafe is loaded
      await fetchSongs(playlist['id'].toString()).then((fetchedSongs) {
        setState(() {
          print(fetchedSongs);
          Songs = fetchedSongs;
          isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        print('Error: $error');
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      print("******************in didChangeDependencies");
      playlist = ModalRoute.of(context)!.settings.arguments;
      print(playlist);
      loadPlaylist();
    });
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
          : Songs.isEmpty
          ? const Center(child: Text("This playlist is currently empty"))
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Songs',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Songs.length,
              itemBuilder: (BuildContext context, int index) {
                final song = Songs[index];
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
                      song['song_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    onTap: () {
                      // Handle the playlist item click
                      // Add your logic here
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
