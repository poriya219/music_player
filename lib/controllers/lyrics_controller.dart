import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class LyricsController extends GetxController {

  String? lyricsString;
  setLyricsString(String? value) {
    lyricsString = value;
    update();
  }

  getLyrics({required String title, required String artist}) async {
    try {
      setLyricsString(null);
      final response = await http
          .get(
            Uri.parse(
                'http://api.chartlyrics.com/apiv1.asmx/SearchLyric?song=$title&artist=$artist'),
          )
          .timeout(const Duration(seconds: 40));

      final document = XmlDocument.parse(response.body);
      print('document: $document');
      Iterable<XmlElement> lyricId = document.findAllElements('LyricId');
      Iterable<XmlElement> checkSum = document.findAllElements('LyricChecksum');
      print('lyricId : ${lyricId.first.innerText}');
      print('checkSum : ${checkSum.first.innerText}');
      final lyricsResponse = await http
          .get(
            Uri.parse(
                'http://api.chartlyrics.com/apiv1.asmx/GetLyric?lyricId=${lyricId.first.innerText}&lyricCheckSum=${checkSum.first.innerText}'),
          )
          .timeout(const Duration(seconds: 40));
      final lyricsDocument = XmlDocument.parse(lyricsResponse.body);
      Iterable<XmlElement> lyrics = lyricsDocument.findAllElements('Lyric');
      print('lyrics: ${lyrics.first.innerText}');
      setLyricsString(lyrics.first.innerText);
    } catch (e) {
      setLyricsString('No lyrics');
      print(e);
    }
  }
}
