package dev.hsichen.colorinvo.widget

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import androidx.core.graphics.createBitmap
import dev.hsichen.colorinvo.data.CarrierSettings
import dev.hsichen.colorinvo.data.Decoration
import dev.hsichen.colorinvo.domain.Code39

object WidgetBitmapRenderer {
    fun render(settings: CarrierSettings, width: Int = 658, height: Int = 310): Bitmap {
        val bitmap = createBitmap(width, height)
        val canvas = Canvas(bitmap)
        val background = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = settings.palette.backgroundColor.argb }
        val foreground = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = settings.palette.barColor.argb }
        canvas.drawRoundRect(RectF(0f, 0f, width.toFloat(), height.toFloat()), 40f, 40f, background)
        when (settings.decoration) {
            Decoration.CAT -> drawCat(canvas, foreground, width, height)
            Decoration.WAVE -> drawWave(canvas, settings, width, height)
            Decoration.NONE -> Unit
        }
        val code = settings.carrierCode.ifEmpty { "/ABC1234" }
        val (bars, totalWidth) = Code39.bars(code)
        val left = 62f
        val right = width - 62f
        val top = 74f
        val bottom = if (settings.showsBarcodeValue) height - 72f else height - 54f
        val unit = (right - left) / totalWidth
        bars.forEach { canvas.drawRect(left + it.startsAt * unit, top, left + (it.startsAt + it.width) * unit, bottom, foreground) }
        if (settings.showsBarcodeValue) {
            foreground.textSize = 34f
            foreground.textAlign = Paint.Align.CENTER
            foreground.typeface = android.graphics.Typeface.MONOSPACE
            canvas.drawText(code, width / 2f, height - 26f, foreground)
        }
        return bitmap
    }

    private fun drawWave(canvas: Canvas, settings: CarrierSettings, width: Int, height: Int) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = settings.dominantColors.firstOrNull()?.argb ?: 0x3370D6FF
            alpha = 52
        }
        canvas.drawCircle(width * 0.9f, height * 0.1f, width * 0.42f, paint)
    }

    private fun drawCat(canvas: Canvas, paint: Paint, width: Int, height: Int) {
        paint.alpha = 28
        val x = width * 0.88f
        val y = height * 0.72f
        val radius = height * 0.18f
        canvas.drawCircle(x, y, radius, paint)
        val path = Path().apply {
            moveTo(x - radius, y - radius * 0.55f)
            lineTo(x - radius * 0.85f, y - radius * 1.75f)
            lineTo(x - radius * 0.2f, y - radius * 0.75f)
            lineTo(x + radius * 0.2f, y - radius * 0.75f)
            lineTo(x + radius * 0.85f, y - radius * 1.75f)
            lineTo(x + radius, y - radius * 0.55f)
            close()
        }
        canvas.drawPath(path, paint)
    }
}
