import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'equalizer_controller.dart';

class EqualizerUiController extends GetxController {
  @override
  void onInit() {
    init();
    super.onInit();
  }

  final equalizer = EqualizerController();

  var bands = <int>[].obs;
  var freqs = <int>[].obs;
  var presets = <String>[].obs;
  var selectedPreset = 0.obs;
  var enabled = false.obs;

  Future<void> init() async {
    final playerController = Get.put(PlayerController());
    int? sessionId = playerController.player.androidAudioSessionId;
    if (sessionId == null) {
      return;
    }
    await equalizer.init(sessionId);
    bands.value = await equalizer.getBandLevels();
    freqs.value = await equalizer.getCenterFrequencies();
    presets.value = await equalizer.getPresets();
    await loadSettings();
  }

  void toggleEnable() async {
    enabled.value = !enabled.value;
    await equalizer.setEnabled(enabled.value);
    saveSettings();
  }

  void setBand(int bandIndex, int level) async {
    bands[bandIndex] = level;
    await equalizer.setBandLevel(bandIndex, level);
    saveSettings();
  }

  void selectPreset(int index) async {
    selectedPreset.value = index;
    await equalizer.usePreset(index);
    bands.value = await equalizer.getBandLevels();
    saveSettings();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('equalizer_enabled', enabled.value);
    prefs.setInt('equalizer_preset', selectedPreset.value);
    for (var i = 0; i < bands.length; i++) {
      prefs.setInt('band_$i', bands[i]);
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Enable/Disable
    enabled.value = prefs.getBool('equalizer_enabled') ?? false;
    await equalizer.setEnabled(enabled.value);

    // Preset
    selectedPreset.value = prefs.getInt('equalizer_preset') ?? 0;
    await equalizer.usePreset(selectedPreset.value);

    // Custom band levels
    for (var i = 0; i < bands.length; i++) {
      final saved = prefs.getInt('band_$i');
      if (saved != null) {
        await equalizer.setBandLevel(i, saved);
        bands[i] = saved;
      }
    }
  }
}
