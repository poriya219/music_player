package com.poqi.music.MusicFlow

import android.media.audiofx.Equalizer
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ContentUris
import android.net.Uri
import android.provider.MediaStore

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "equalizer_channel"
    private var equalizer: Equalizer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initEqualizer" -> {
                    val sessionId = call.argument<Int>("sessionId") ?: 0
                    equalizer = Equalizer(0, sessionId).apply { enabled = true }
                    result.success(true)
                }

                "getBandLevels" -> {
                    val levels = mutableListOf<Int>()
                    equalizer?.let {
                        for (i in 0 until it.numberOfBands) {
                            levels.add(it.getBandLevel(i.toShort()).toInt())
                        }
                    }
                    result.success(levels)
                }

                "getCenterFrequencies" -> {
                    val freqs = mutableListOf<Int>()
                    equalizer?.let {
                        for (i in 0 until it.numberOfBands) {
                            freqs.add(it.getCenterFreq(i.toShort()) / 1000)
                        }
                    }
                    result.success(freqs)
                }

                "getPresets" -> {
                    val presets = mutableListOf<String>()
                    equalizer?.let {
                        for (i in 0 until it.numberOfPresets) {
                            presets.add(it.getPresetName(i.toShort()))
                        }
                    }
                    result.success(presets)
                }

                "usePreset" -> {
                    val index = call.argument<Int>("index") ?: 0
                    equalizer?.usePreset(index.toShort())
                    result.success(true)
                }

                "setBandLevel" -> {
                    val bandIndex = call.argument<Int>("bandIndex") ?: 0
                    val level = call.argument<Int>("level") ?: 0
                    equalizer?.setBandLevel(bandIndex.toShort(), level.toShort())
                    result.success(true)
                }

                "setEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    equalizer?.enabled = enabled
                    result.success(true)
                }

                "removeFromPlaylist" -> {
                    val playlistId = (call.argument<Int>("playlistId") ?: -1).toLong()
                    val audioId = (call.argument<Int>("audioId") ?: -1).toLong()

        val uri: Uri = MediaStore.Audio.Playlists.Members.getContentUri("external", playlistId)
        val selection = "${MediaStore.Audio.Playlists.Members.AUDIO_ID}=?"
        val selectionArgs = arrayOf(audioId.toString())

        val rowsDeleted = contentResolver.delete(uri, selection, selectionArgs)
        result.success(rowsDeleted)
    }

    "deletePlaylist" -> {
        val playlistId = (call.argument<Int>("playlistId") ?: -1).toLong()
        val uri = ContentUris.withAppendedId(MediaStore.Audio.Playlists.EXTERNAL_CONTENT_URI, playlistId)

        val rowsDeleted = contentResolver.delete(uri, null, null)
        result.success(rowsDeleted)
    }

                else -> result.notImplemented()
            }
        }
    }
}