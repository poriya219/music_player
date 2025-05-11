import 'dart:convert';

import 'package:http/http.dart' as http;

class Network {
  Future<List> getSimilarSongs(
      {required String title, required String artist}) async {
    try {
      final response = await http.get(Uri.parse(
          'https://spotify-bridge-5ece.globeapp.dev/spotify/similar?title=$title&artist=$artist'));
      Map data = jsonDecode(response.body);
      Map tracks = data['tracks'] ?? {};
      List items = tracks['items'] ?? [];
      return items;
    } catch (e) {
      return [];
    }
  }

  Future<http.Response> getSongLyrics(
      {required String title, required String artist}) async {
    try {
      final response = await http.get(Uri.parse(
          'https://spotify-bridge-5ece.globeapp.dev/lyrics?title=$title&artist=$artist'));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({}), 500);
    }
  }
}
