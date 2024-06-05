import 'dart:typed_data';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../constans.dart';
import '../../../controllers/app_controller.dart';

class ListDetail extends StatelessWidget {
  final dynamic model;
  final ListDetailMode mode;
  ListDetail({super.key, required this.model, required this.mode});

  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              EvaIcons.arrowBack,
              color: Theme.of(context).iconTheme.color,
            )),
      ),
      body: SafeArea(child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Expanded(child: FutureBuilder(future: getList(mode: mode,model: model), builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30.w,
                          height: 30.w,
                          child: FutureBuilder(future: getImage(mode: mode, id: model.id),
                              builder: (context, AsyncSnapshot snapshot){
                            if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                              Uint8List? data = snapshot.data;
                              if(data != null){
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(data,
                                    width: 30.w,
                                    height: 30.w,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              else{
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset('assets/images/bd.png',
                                    width: 6.h,
                                    height: 6.h,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            }
                            else{
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset('assets/images/gd.png',
                                  width: 6.h,
                                  height: 6.h,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                          }),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(getTitle(mode: mode, model: model)[0],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: kTextGreyColor),
                            ),
                            Text(getTitle(mode: mode, model: model)[1],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            );
          }
          else{
            return const SizedBox();
          }
        })),
      ),),
    );
  }

  List<String> getTitle({required ListDetailMode mode, required dynamic model}){
    switch(mode){
      case ListDetailMode.album:
        return ['ALBUM - ${model.numOfSongs} SONG','${model.album}'];
      case ListDetailMode.artist:
        return ['ARTIST - ${model.numberOfTracks} SONG','${model.artist}'];
      case ListDetailMode.genre:
        return ['GENRE - ${model.numOfSongs} SONG','${model.genre}'];
      default:
        return ['',''];
    }
  }

  Future getImage({required ListDetailMode mode, required int id}) async{
    switch(mode){
      case ListDetailMode.album:
        return controller.getAlbumImage(id);
      case ListDetailMode.artist:
        return controller.getArtistImage(id);
      case ListDetailMode.genre:
        return controller.getGenreImage(id);
      default:
        controller.getSongImage(id);
    }
  }

  Future<List<SongModel>> getList({required dynamic model, required ListDetailMode mode}) async{
    try{
      OnAudioQuery onAudioQuery = OnAudioQuery();
      var list = await onAudioQuery.queryAudiosFrom(getType(mode: mode), model.id);
      return list;
    }
        catch(e){
      return [];
        }
  }

  AudiosFromType getType({required ListDetailMode mode}){
    switch(mode){
      case ListDetailMode.genre:
        return AudiosFromType.GENRE_ID;
      case ListDetailMode.artist:
        return AudiosFromType.ARTIST_ID;
      case ListDetailMode.album:
        return AudiosFromType.ALBUM_ID;
      default:
        return AudiosFromType.ALBUM_ID;
    }
  }
}

enum ListDetailMode {
  artist,
  album,
  genre,
}
