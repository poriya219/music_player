import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/constans.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen/widgets/songs_list.dart';
import 'controller/search_controller.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final searchController = Get.put(SearchScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<SearchScreenController>(builder: (sController){
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Get.back();
                      },
                      child: Icon(EvaIcons.arrowIosBack),
                    ),
                    Expanded(child: Container(
                      height: 5.h,
                      margin: EdgeInsets.only(left: 4.w),
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCCCCC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: searchController.textEditingController,
                          onChanged: (value){
                            searchController.update();
                            if(value.isNotEmpty){
                              searchController.searchSongs();
                            }
                            else{
                              searchController.setSearchedSongs([]);
                            }
                            Timer(const Duration(seconds: 5), () async{
                              if(searchController.textEditingController.text.isNotEmpty && searchController.textEditingController.text == value){
                                final prefs = await SharedPreferences.getInstance();
                                List<String> history = prefs.getStringList('SearchHistory') ?? [];
                                history.add(value);
                                prefs.setStringList('SearchHistory', history);
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for songs on device',
                            contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                            hintStyle: TextStyle(
                              fontSize: 15.sp
                            ),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none
                            )
                          ),
                        ))),
                  ],
                ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Visibility(
                  visible: searchController.textEditingController.text.isEmpty,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Search history',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                      ),
                      ),
                      GestureDetector(
                        onTap: () async{
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setStringList('SearchHistory', []);
                          searchController.setHistory([]);
                        },
                        child: Icon(EvaIcons.trash2),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: searchController.textEditingController.text.isEmpty,
                  child: SizedBox(
                      width: 90.w,
                      height: 6.h,
                      child: ListView.builder(
                      itemCount: searchController.history.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        return historyContainer(title: searchController.history[index]);
                      })),
                ),
                Visibility(
                    visible: searchController.searchedSongs.isNotEmpty,
                    child: Expanded(child: SongsList(songs: searchController.searchedSongs))),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget historyContainer({required String title}) {
    return GestureDetector(
        onTap: () {
          searchController.setControllerText(title);
          searchController.searchSongs();
        },
        child: Container(
          // height: 3.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: kTextGreyColor),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: kBlueColor,
              ),
            ),
          ),
        ));
  }
}
