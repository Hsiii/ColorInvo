package dev.hsichen.colorinvo.domain

import android.graphics.Color
import kotlin.math.max
import kotlin.math.min

data class RgbaColor(
    val red: Double,
    val green: Double,
    val blue: Double,
    val alpha: Double = 1.0,
) {
    constructor(hex: Long) : this(
        red = ((hex shr 16) and 0xff) / 255.0,
        green = ((hex shr 8) and 0xff) / 255.0,
        blue = (hex and 0xff) / 255.0,
    )

    val argb: Int
        get() = Color.argb(
            (alpha * 255).toInt().coerceIn(0, 255),
            (red * 255).toInt().coerceIn(0, 255),
            (green * 255).toInt().coerceIn(0, 255),
            (blue * 255).toInt().coerceIn(0, 255),
        )

    val hex: String
        get() = "#%02X%02X%02X".format(
            (red * 255).toInt().coerceIn(0, 255),
            (green * 255).toInt().coerceIn(0, 255),
            (blue * 255).toInt().coerceIn(0, 255),
        )

    val scannerReflectance: Double get() = red

    val isReddish: Boolean
        get() {
            val maximum = max(red, max(green, blue))
            val minimum = min(red, min(green, blue))
            val chroma = maximum - minimum
            if (chroma <= 0.12 || maximum <= 0.18) return false
            val hue = when (maximum) {
                red -> 60 * (((green - blue) / chroma) % 6)
                green -> 60 * (((blue - red) / chroma) + 2)
                else -> 60 * (((red - green) / chroma) + 4)
            }.let { if (it < 0) it + 360 else it }
            return hue <= 40 || hue >= 340
        }

    companion object {
        fun parse(value: String): RgbaColor? {
            val normalized = value.trim().removePrefix("#")
            if (!normalized.matches(Regex("[0-9a-fA-F]{6}"))) return null
            return RgbaColor(normalized.toLong(16))
        }
    }
}

data class BarcodePalette(
    val name: String,
    val barColor: RgbaColor,
    val backgroundColor: RgbaColor,
) {
    val scannerSymbolContrast: Double
        get() = (backgroundColor.scannerReflectance - barColor.scannerReflectance).coerceAtLeast(0.0)

    val meetsCommercialGuidance: Boolean
        get() = backgroundColor.scannerReflectance >= MINIMUM_BACKGROUND_REFLECTANCE &&
            barColor.scannerReflectance <= backgroundColor.scannerReflectance / 2 &&
            scannerSymbolContrast >= SYMBOL_CONTRAST_STANDARD &&
            !barColor.isReddish

    val standardMessage: String
        get() = when {
            meetsCommercialGuidance -> "可掃描配色"
            barColor.isReddish -> "條碼勿用紅系"
            backgroundColor.scannerReflectance < MINIMUM_BACKGROUND_REFLECTANCE -> "背景與靜區要更亮"
            barColor.scannerReflectance > backgroundColor.scannerReflectance / 2 -> "條碼在紅光下要更深"
            else -> "符號反差不足"
        }

    companion object {
        const val SYMBOL_CONTRAST_STANDARD = 0.70
        const val MINIMUM_BACKGROUND_REFLECTANCE = 0.70
        val Classic = BarcodePalette("經典黑白", RgbaColor(0x000000), RgbaColor(0xFFFFFF))
    }
}
