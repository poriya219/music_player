import 'package:http/http.dart' as http;

class Network {
  getLyricsId({required String title, required String artist}) async{
    var response = await http.get(Uri.parse('http://api.chartlyrics.com/apiv1.asmx/SearchLyric?song=$title&artist=$artist'),);
  }
}