package dev.hsichen.colorinvo.data

import android.content.Context
import androidx.core.content.edit
import dev.hsichen.colorinvo.domain.BarcodePalette
import dev.hsichen.colorinvo.domain.RgbaColor

enum class Decoration { CAT, WAVE, NONE }

data class CarrierSettings(
    val carrierCode: String = "",
    val palette: BarcodePalette = BarcodePalette.Classic,
    val dominantColors: List<RgbaColor> = emptyList(),
    val decoration: Decoration = Decoration.CAT,
    val showsBarcodeValue: Boolean = true,
)

class CarrierStore(context: Context) {
    private val preferences = context.getSharedPreferences("carrier-settings", Context.MODE_PRIVATE)

    fun load(): CarrierSettings = CarrierSettings(
        carrierCode = preferences.getString("carrierCode", "").orEmpty(),
        palette = BarcodePalette(
            name = "自訂",
            barColor = RgbaColor.parse(preferences.getString("barColor", null).orEmpty())
                ?: BarcodePalette.Classic.barColor,
            backgroundColor = RgbaColor.parse(preferences.getString("backgroundColor", null).orEmpty())
                ?: BarcodePalette.Classic.backgroundColor,
        ),
        dominantColors = preferences.getString("dominantColors", "")
            .orEmpty()
            .split(',')
            .mapNotNull(RgbaColor::parse),
        decoration = preferences.getString("decoration", null)
            ?.let { runCatching { Decoration.valueOf(it) }.getOrNull() }
            ?: Decoration.CAT,
        showsBarcodeValue = preferences.getBoolean("showsBarcodeValue", true),
    )

    fun save(settings: CarrierSettings) {
        preferences.edit {
            putString("carrierCode", settings.carrierCode)
            putString("barColor", settings.palette.barColor.hex)
            putString("backgroundColor", settings.palette.backgroundColor.hex)
            putString("dominantColors", settings.dominantColors.joinToString(",") { it.hex })
            putString("decoration", settings.decoration.name)
            putBoolean("showsBarcodeValue", settings.showsBarcodeValue)
        }
    }
}
