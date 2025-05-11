import 'package:MusicFlow/constans.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/equalizer_ui_controller.dart';

class EqualizerScreen extends StatelessWidget {
  final controller = Get.put(EqualizerUiController());

  EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('t25'.tr),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: kBackIcon()),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Obx(() {
          return controller.bands.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('t26'.tr),
                        Switch(
                            activeColor: kBlueColor,
                            inactiveThumbColor: kGreyColor,
                            inactiveTrackColor: Colors.grey,
                            value: controller.enabled.value,
                            onChanged: (val) => controller.toggleEnable())
                      ],
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('t27'.tr),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                              border: Border.all(color: kGreyColor),
                              borderRadius: BorderRadius.circular(15)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.selectedPreset.value,
                              items: controller.presets
                                  .asMap()
                                  .entries
                                  .map((e) => DropdownMenuItem<int>(
                                        value: e.key,
                                        child: Text(e.value),
                                      ))
                                  .toList(),
                              onChanged: (index) {
                                if (index != null) {
                                  controller.selectPreset(index);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.bands.length,
                        itemBuilder: (context, index) {
                          final freq = controller.freqs[index];
                          final level = controller.bands[index];
                          return Column(
                            children: [
                              Text('${freq} Hz'),
                              Slider(
                                min: -1500,
                                max: 1500,
                                value: level.toDouble(),
                                activeColor: kBlueColor,
                                inactiveColor: Colors.grey,
                                divisions: 30,
                                label: '${level} dB',
                                onChanged: (val) =>
                                    controller.setBand(index, val.toInt()),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
        }),
      ),
    );
  }
}
