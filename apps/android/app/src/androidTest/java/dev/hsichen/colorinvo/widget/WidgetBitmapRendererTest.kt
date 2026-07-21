package dev.hsichen.colorinvo.widget

import androidx.test.ext.junit.runners.AndroidJUnit4
import dev.hsichen.colorinvo.data.CarrierSettings
import dev.hsichen.colorinvo.domain.BarcodePalette
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class WidgetBitmapRendererTest {
    @Test fun rendersConfiguredBackgroundAndBarcode() {
        val bitmap = WidgetBitmapRenderer.render(
            CarrierSettings(carrierCode = "/ABC1234", palette = BarcodePalette.Classic),
        )
        assertEquals(BarcodePalette.Classic.backgroundColor.argb, bitmap.getPixel(329, 30))
        assertNotEquals(BarcodePalette.Classic.backgroundColor.argb, bitmap.getPixel(70, 100))
    }
}
