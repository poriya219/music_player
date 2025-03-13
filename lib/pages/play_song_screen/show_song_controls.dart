import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ShowSongControls extends StatelessWidget {
  final QueryArtworkWidget artwork;
  const ShowSongControls({super.key, required this.artwork});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      height: 80.h,
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.transparent],
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: artwork,
      ),
    );
  }
}
