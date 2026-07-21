package dev.hsichen.colorinvo.domain

import android.graphics.Bitmap
import androidx.core.graphics.get
import androidx.core.graphics.scale

object WallpaperPaletteGenerator {
    fun representativeColors(bitmap: Bitmap): List<RgbaColor> {
        val sample = bitmap.scale(40, 40)
        val buckets = mutableMapOf<Int, ColorBucket>()
        for (y in 0 until sample.height) for (x in 0 until sample.width) {
            val pixel = sample[x, y]
            val red = android.graphics.Color.red(pixel) / 255.0
            val green = android.graphics.Color.green(pixel) / 255.0
            val blue = android.graphics.Color.blue(pixel) / 255.0
            val maximum = maxOf(red, green, blue)
            val minimum = minOf(red, green, blue)
            val saturation = if (maximum == 0.0) 0.0 else (maximum - minimum) / maximum
            val key = ((red * 5).toInt() shl 8) or ((green * 5).toInt() shl 4) or (blue * 5).toInt()
            val weight = 1 + saturation * 0.35
            val bucket = buckets.getOrPut(key) { ColorBucket() }
            bucket.weight += weight
            bucket.red += red * weight
            bucket.green += green * weight
            bucket.blue += blue * weight
        }
        if (sample !== bitmap) sample.recycle()
        return buckets.values.sortedByDescending(ColorBucket::weight).map {
            RgbaColor(it.red / it.weight, it.green / it.weight, it.blue / it.weight)
        }.fold(emptyList<RgbaColor>()) { result, candidate ->
            if (result.size >= 3 || result.any { colorDistance(it, candidate) < 0.16 }) result
            else result + candidate
        }.ifEmpty { listOf(RgbaColor(0x70D6FF)) }
    }

    fun palettes(colors: List<RgbaColor>): List<BarcodePalette> = colors.take(3).mapIndexed { index, color ->
        val background = mix(color, RgbaColor(0xFFFFFF), 0.82).ensureRedAtLeast(0.74)
        val barSeed = RgbaColor(color.blue * 0.2, color.green * 0.22, color.red * 0.18)
        val bar = mix(barSeed, RgbaColor(0x000000), 0.48).copy(red = minOf(barSeed.red * 0.52, 0.04))
        BarcodePalette("桌布配色 ${index + 1}", bar, background)
    }

    private fun mix(first: RgbaColor, second: RgbaColor, amount: Double) = RgbaColor(
        first.red + (second.red - first.red) * amount,
        first.green + (second.green - first.green) * amount,
        first.blue + (second.blue - first.blue) * amount,
    )

    private fun RgbaColor.ensureRedAtLeast(minimum: Double): RgbaColor =
        if (red >= minimum) this else copy(red = minimum)

    private fun colorDistance(first: RgbaColor, second: RgbaColor): Double =
        kotlin.math.sqrt(
            (first.red - second.red).let { it * it } +
                (first.green - second.green).let { it * it } +
                (first.blue - second.blue).let { it * it },
        )

    private class ColorBucket(
        var weight: Double = 0.0,
        var red: Double = 0.0,
        var green: Double = 0.0,
        var blue: Double = 0.0,
    )
}
