package dev.hsichen.colorinvo.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class WallpaperPaletteGeneratorTest {
    @Test fun createsThreeScannerReadyPalettes() {
        val palettes = WallpaperPaletteGenerator.palettes(
            listOf(RgbaColor(0x70D6FF), RgbaColor(0xFF9770), RgbaColor(0x396791)),
        )
        assertEquals(3, palettes.size)
        assertTrue(palettes.all(BarcodePalette::meetsCommercialGuidance))
    }
}
