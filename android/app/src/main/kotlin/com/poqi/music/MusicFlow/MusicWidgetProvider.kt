package com.poqi.music.MusicFlow

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import com.poqi.music.MusicFlow.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File
import android.net.Uri

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

            views.setOnClickPendingIntent(
    R.id.btn_play_pause,
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("myAppWidget://toggle"))
)

views.setOnClickPendingIntent(
    R.id.btn_next,
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("myAppWidget://next"))
)

views.setOnClickPendingIntent(
    R.id.btn_previous,
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("myAppWidget://prev"))
)

views.setOnClickPendingIntent(
    R.id.btn_like,
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("myAppWidget://like"))
)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}