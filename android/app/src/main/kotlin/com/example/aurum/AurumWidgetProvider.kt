package com.example.aurum

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AurumWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Fetch data from SharedPreferences saved by HomeWidget Flutter plugin
                val price24k = widgetData.getString("gold_24k_price", "Gold price unavailable")
                val price22k = widgetData.getString("gold_22k_price", "")
                val updatedAt = widgetData.getString("gold_updated_at", "Open Aurum to refresh")

                // Update the TextViews in the widget layout
                setTextViewText(R.id.gold_24k_price, price24k)
                setTextViewText(R.id.gold_22k_price, price22k)
                setTextViewText(R.id.gold_updated_at, updatedAt)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
