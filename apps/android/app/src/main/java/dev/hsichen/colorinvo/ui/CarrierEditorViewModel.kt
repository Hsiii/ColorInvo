package dev.hsichen.colorinvo.ui

import android.app.Application
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.glance.appwidget.updateAll
import dev.hsichen.colorinvo.data.CarrierSettings
import dev.hsichen.colorinvo.data.CarrierStore
import dev.hsichen.colorinvo.data.Decoration
import dev.hsichen.colorinvo.domain.BarcodePalette
import dev.hsichen.colorinvo.domain.CarrierCode
import dev.hsichen.colorinvo.domain.RgbaColor
import dev.hsichen.colorinvo.domain.WallpaperPaletteGenerator
import dev.hsichen.colorinvo.widget.ColorInvoWidget
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

data class CarrierEditorState(
    val settings: CarrierSettings,
    val wallpaperPalettes: List<BarcodePalette> = emptyList(),
    val isAnalyzingWallpaper: Boolean = false,
    val wallpaperError: Boolean = false,
    val isSaving: Boolean = false,
) {
    val carrierSuffix get() = settings.carrierCode.removePrefix("/")
    val carrierIsValid get() = CarrierCode.isValid(settings.carrierCode)
}

class CarrierEditorViewModel(application: Application) : AndroidViewModel(application) {
    private val store = CarrierStore(application)
    private var saveJob: Job? = null
    var state = androidx.compose.runtime.mutableStateOf(
        store.load().let { settings ->
            CarrierEditorState(settings, WallpaperPaletteGenerator.palettes(settings.dominantColors))
        },
    )
        private set

    fun updateCarrierSuffix(value: String) = updateSettings {
        copy(carrierCode = CarrierCode.fromSuffix(value))
    }

    fun updateBarColor(value: String) {
        RgbaColor.parse(value)?.let { color -> updateSettings { copy(palette = palette.copy(name = "自訂", barColor = color)) } }
    }

    fun updateBackgroundColor(value: String) {
        RgbaColor.parse(value)?.let { color -> updateSettings { copy(palette = palette.copy(name = "自訂", backgroundColor = color)) } }
    }

    fun selectPalette(palette: BarcodePalette) = updateSettings { copy(palette = palette) }

    fun setDecoration(decoration: Decoration) = updateSettings { copy(decoration = decoration) }

    fun setShowsBarcodeValue(value: Boolean) = updateSettings { copy(showsBarcodeValue = value) }

    fun loadWallpaper(uri: Uri) {
        state.value = state.value.copy(isAnalyzingWallpaper = true, wallpaperError = false)
        viewModelScope.launch {
            val colors = withContext(Dispatchers.IO) {
                runCatching {
                    getApplication<Application>().contentResolver.openInputStream(uri)?.use {
                        BitmapFactory.decodeStream(it)
                    }?.let(WallpaperPaletteGenerator::representativeColors)
                }.getOrNull()
            }
            if (colors.isNullOrEmpty()) {
                state.value = state.value.copy(isAnalyzingWallpaper = false, wallpaperError = true)
                return@launch
            }
            val palettes = WallpaperPaletteGenerator.palettes(colors)
            state.value = state.value.copy(
                settings = state.value.settings.copy(dominantColors = colors, palette = palettes.first()),
                wallpaperPalettes = palettes,
                isAnalyzingWallpaper = false,
            )
            scheduleSave()
        }
    }

    private fun updateSettings(transform: CarrierSettings.() -> CarrierSettings) {
        state.value = state.value.copy(settings = state.value.settings.transform())
        scheduleSave()
    }

    private fun scheduleSave() {
        saveJob?.cancel()
        state.value = state.value.copy(isSaving = true)
        saveJob = viewModelScope.launch {
            delay(350)
            val settings = state.value.settings
            withContext(Dispatchers.IO) { store.save(settings) }
            ColorInvoWidget().updateAll(getApplication())
            state.value = state.value.copy(isSaving = false)
        }
    }
}
