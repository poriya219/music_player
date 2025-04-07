import 'dart:convert';

import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;

class LyricsController extends GetxController {
  List<String>? lyricsString;
  setLyricsString(List<String>? value) {
    lyricsString = value;
    update();
  }

  getLyrics({required String title, required String artist}) async {
    try {
      setLyricsString(null);
      // final response = await http
      //     .get(
      //       Uri.parse(
      //           'http://api.chartlyrics.com/apiv1.asmx/SearchLyric?song=$title&artist=$artist'),
      //     )
      //     .timeout(const Duration(seconds: 40));
      //
      // final document = XmlDocument.parse(response.body);
      // Iterable<XmlElement> lyricId = document.findAllElements('LyricId');
      // Iterable<XmlElement> checkSum = document.findAllElements('LyricChecksum');
      // final lyricsResponse = await http
      //     .get(
      //       Uri.parse(
      //           'http://api.chartlyrics.com/apiv1.asmx/GetLyric?lyricId=${lyricId.first.innerText}&lyricCheckSum=${checkSum.first.innerText}'),
      //     )
      //     .timeout(const Duration(seconds: 40));
      // final lyricsDocument = XmlDocument.parse(lyricsResponse.body);
      // Iterable<XmlElement> lyrics = lyricsDocument.findAllElements('Lyric');
      // setLyricsString(lyrics.first.innerText);
      if (title != 'Unknown' || artist != 'Unknown') {
        const String cId =
            "4qiX3aqJxsi0a8s3loupS9l8b1ieM7yCY6oiHmuSINggszNv9sGTvt5hp0PQHowK";
        const String cSecret =
            "81d1vo2uosuC2AAAOSdJOVZrPG4A9mC1YCROPXqXO6mzV28ReYD8WLK0yohlWnKsgnGzZK5bxFeJKvCkj0kf8A";
        const String cToken =
            "Cos-NlfORWlLu61wHf0rtKl00QdYvNn_4uI_5XaTfw2lavQnlbL_6CIFFNZzy6E0";
        final searchUrl = Uri.parse(
            'https://api.genius.com/search?q=${Uri.encodeComponent("$title $artist")}');

        final response = await http.get(
          searchUrl,
          headers: {
            'Authorization': 'Bearer $cToken',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final hits = data['response']['hits'];

          if (hits.isNotEmpty) {
            final songPath = hits[0]['result']['path'];
            final fullUrl = 'https://genius.com$songPath';

            final lyricsPage = await http.get(Uri.parse(fullUrl));
            if (lyricsPage.statusCode == 200) {
              final document = htmlParser.parse(lyricsPage.body);

              final lyricsContainers =
                  document.querySelectorAll('[data-lyrics-container="true"]');

              if (lyricsContainers.isEmpty) {
                setLyricsString(['No lyrics']);
                return;
              }

              for (var container in lyricsContainers) {
                container
                    .querySelectorAll('[data-exclude-from-selection]')
                    .forEach((element) {
                  element.remove(); // حذفشون کن از DOM
                });
              }

              final List<String> lyricsLines = [];

              for (var container in lyricsContainers) {
                for (var node in container.nodes) {
                  if (node.nodeType == dom.Node.TEXT_NODE) {
                    final text = node.text?.trim();
                    if (text != null && text.isNotEmpty) {
                      lyricsLines.add(text);
                    }
                  } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
                    final elementText = (node as dom.Element).text.trim();
                    if (elementText.isNotEmpty) {
                      lyricsLines.add(elementText);
                    }
                  }
                }
              }

              setLyricsString(lyricsLines);
            } else {
              setLyricsString(['Failed to load lyrics page']);
            }
          } else {
            setLyricsString(['No lyrics']);
          }
        } else {
          setLyricsString(['Failed to search song']);
        }
        // final response = await http
        //     .get(Uri.parse('https://api.lyrics.ovh/v1/$artist/$title'));
        // Map data = json.decode(response.body);
        // String ly = data['lyrics'] ?? '';
        // setLyricsString(ly.isNotEmpty ? ly : 'No lyrics');
      }
    } catch (e) {
      setLyricsString(['No lyrics']);
    }
  }
}
