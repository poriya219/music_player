import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SimilarController extends GetxController {
  // String apiKey = 'd12bd00e0e2470b0a528f66f64e53731';
  // String secretKey = '4a48cb9a79a6e0c8e93d796372965682';
  // String baseUrl = 'http://ws.audioscrobbler.com/2.0';
  //
  //
  // getSimilar({required String title, required String artist}) async {
  //   try{
  //     if(!(title == 'Unknown' && artist == 'Unknown')){
  //       setSimilarSongs(null);
  //       http.Response response = await http.get(Uri.parse(
  //           '$baseUrl/?method=track.getsimilar&artist=$artist&track=$title&api_key=$apiKey&autocorrect=1&format=json'));
  //       Map body = json.decode(response.body);
  //       Map similarTracks = body['similartracks'] ?? {};
  //       List tracks = similarTracks['track'] ?? [];
  //       setSimilarSongs(tracks);
  //       print('similar response: $tracks');
  //     }
  //   }
  //       catch(e){
  //     print('error in similar response: $e');
  //     print(e);
  //       }
  // }

  @override
  void onInit() {
    getToken();
    super.onInit();
  }

  String clientId = '0170e95001474ff290f4063e6d014bec';
  String clientSecret = 'd4bcd0cd828943cfa8912ccaa89bc88d';

  String? token;
  setToken(String? value){
    token = value;
    update();
  }

  List? similarSongs;
  setSimilarSongs(List? value){
    similarSongs = value;
    update();
  }

  Future<int> getToken() async{
    try{
      final response = await http.post(
          Uri.parse("https://accounts.spotify.com/api/token"),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: {
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret
          }
      );
      Map data = json.decode(response.body);
      String token = data['access_token'] ?? '';
      String type = data['token_type'] ?? '';
      String finalToken = token.isNotEmpty && type.isNotEmpty ? '$type $token' : '';
      // print('spotifyToken = $finalToken');
      setToken(finalToken);
      return response.statusCode;
    }
    catch(e){
      setToken(null);
      return 0;
    }
  }

  Future<String> getTrackId({required String title, required String artist}) async{
    try{
      final response = await http.get(Uri.parse('https://api.spotify.com/v1/search?q=track:$title artist:$artist&type=track'),
          headers: {
            'Authorization': token ?? '',
          }
      );
      if(response.statusCode == 401){
        await getToken();
        String retryId = await getTrackId(title: title, artist: artist);
        return retryId;
      }
      else{
        Map data = json.decode(response.body);
        Map tracks = data['tracks'] ?? {};
        List items = tracks['items'] ?? [];
        if(items.isNotEmpty){
          Map track = items[0];
          String id = track['id'].toString() ?? '';
          return id;
        }
        else{
          return '';
        }
      }
    }
        catch(e){
      return '';
        }
  }

  String? currentProgress;

  getSimilarTracks({required String title, required String artist}) async {
    if(title != 'Unknown' || artist != 'Unknown'){
      if(title != currentProgress){
        currentProgress = title;
        setSimilarSongs(null);
        if (token != null) {
          String trackId = await getTrackId(
              title: title, artist: artist);
          if (trackId.isNotEmpty) {
            final response = await http.get(Uri.parse(
                'https://api.spotify.com/v1/recommendations?seed_tracks=$trackId'),
                headers: {
                  'Authorization': token ?? '',
                }
            );
            Map data = json.decode(response.body);
            List tracks = data['tracks'] ?? [];
            setSimilarSongs(tracks);
          }
        }
        else{
          int status = await getToken();
          if(status == 200){
            getSimilarTracks(title: title, artist: artist);
          }
        }
      }
    }
    currentProgress = null;
  }
}
