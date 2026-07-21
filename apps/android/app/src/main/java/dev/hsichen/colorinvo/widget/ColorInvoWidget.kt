package dev.hsichen.colorinvo.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.layout.ContentScale
import androidx.glance.layout.fillMaxSize
import dev.hsichen.colorinvo.MainActivity
import dev.hsichen.colorinvo.data.CarrierStore

class ColorInvoWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val bitmap = WidgetBitmapRenderer.render(CarrierStore(context).load())
        provideContent { WidgetContent(bitmap) }
    }
}

@Composable
private fun WidgetContent(bitmap: android.graphics.Bitmap) {
    Image(
        provider = ImageProvider(bitmap),
        contentDescription = "ColorInvo carrier barcode",
        contentScale = ContentScale.FillBounds,
        modifier = GlanceModifier
            .fillMaxSize()
            .clickable(actionStartActivity(MainActivity::class.java)),
    )
}

class ColorInvoWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = ColorInvoWidget()
}
