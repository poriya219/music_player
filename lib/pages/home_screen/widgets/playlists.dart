import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Playlists extends StatelessWidget {
  final List<PlaylistModel> playlists;
  const Playlists({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 8/7,),
      itemCount: playlists.length,
      shrinkWrap: true,
      itemBuilder: (context, index) => playlistCard(
        playlist: playlists[index],
      ),
    );
  }

  Widget playlistCard({required PlaylistModel playlist}) {
    print(playlist.getMap.toString());
    print(playlist.data);
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          child: Center(child: Text('still in progress :(')),
        ),
      ],
    );
  }
}
