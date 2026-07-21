package dev.hsichen.colorinvo.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class BarcodePaletteTest {
    @Test fun classicPaletteMeetsScannerGuidance() {
        assertTrue(BarcodePalette.Classic.meetsCommercialGuidance)
    }

    @Test fun redBarsAreRejected() {
        val palette = BarcodePalette("red", RgbaColor(0xFF0000), RgbaColor(0xFFFFFF))
        assertFalse(palette.meetsCommercialGuidance)
        assertEquals("條碼勿用紅系", palette.standardMessage)
    }

    @Test fun hexColorsRoundTrip() {
        assertEquals("#70D6FF", RgbaColor.parse("#70d6ff")?.hex)
    }
}
