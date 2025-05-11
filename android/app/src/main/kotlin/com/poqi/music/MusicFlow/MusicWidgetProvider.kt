package com.poqi.music.MusicFlow

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import com.poqi.music.MusicFlow.R
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetBackgroundReceiver
import java.io.File

class MusicWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)

        val prefs = HomeWidgetPlugin.getData(context)
        val title = prefs.getString("title", "Unknown Title")
        val artist = prefs.getString("artist", "Unknown Artist")
        val imagePath = prefs.getString("image", null)
        val isPlaying = prefs.getBoolean("isPlaying", false)
        val isLiked = prefs.getBoolean("isLiked", false)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.music_widget)

            views.setTextViewText(R.id.song_title, title)
            views.setTextViewText(R.id.song_artist, artist)

            if (!imagePath.isNullOrEmpty()) {
                val file = File(imagePath)
                if (file.exists()) {
                    val bitmap = BitmapFactory.decodeFile(file.path)
                    views.setImageViewBitmap(R.id.song_image, bitmap)
                }
            }

            views.setImageViewResource(
                R.id.btn_play_pause,
                if (isPlaying) R.drawable.pa else R.drawable.p
            )

            views.setImageViewResource(
                R.id.btn_like,
                if (isLiked) R.drawable.liked else R.drawable.like
            )

            // دکمه‌ها با PendingIntent که به MainActivity می‌روند
            views.setOnClickPendingIntent(R.id.btn_play_pause, getPendingIntent(context, "myAppWidget://play_pause"))
            views.setOnClickPendingIntent(R.id.btn_next, getPendingIntent(context, "myAppWidget://next"))
            views.setOnClickPendingIntent(R.id.btn_previous, getPendingIntent(context, "myAppWidget://previous"))
            views.setOnClickPendingIntent(R.id.btn_like, getPendingIntent(context, "myAppWidget://like"))

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun getPendingIntent(context: Context, uri: String): PendingIntent {
        val intent = Intent(context, HomeWidgetBackgroundReceiver::class.java).apply {
            this.data = Uri.parse(uri)
        }
        return PendingIntent.getBroadcast(
            context,
            uri.hashCode(),  // برای یکتا بودن
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}