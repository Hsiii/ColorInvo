package dev.hsichen.colorinvo.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import dev.hsichen.colorinvo.data.CarrierSettings
import dev.hsichen.colorinvo.data.Decoration
import dev.hsichen.colorinvo.domain.Code39

@Composable
fun CarrierPreview(settings: CarrierSettings, modifier: Modifier = Modifier) {
    val background = Color(settings.palette.backgroundColor.argb)
    val foreground = Color(settings.palette.barColor.argb)
    Box(
        modifier = modifier
            .background(background)
            .semantics { contentDescription = "載具條碼預覽 ${settings.carrierCode}" },
    ) {
        if (settings.decoration == Decoration.WAVE && settings.dominantColors.isNotEmpty()) {
            Canvas(Modifier.fillMaxSize()) {
                drawCircle(
                    color = Color(settings.dominantColors.first().argb).copy(alpha = 0.22f),
                    radius = size.width * 0.55f,
                    center = Offset(size.width * 0.86f, size.height * 0.18f),
                )
            }
        }
        if (settings.decoration == Decoration.CAT) {
            CatDecoration(foreground.copy(alpha = 0.13f), Modifier.align(Alignment.BottomEnd).padding(12.dp))
        }
        val code = settings.carrierCode.ifEmpty { "/ABC1234" }
        Barcode(
            value = code,
            color = foreground,
            modifier = Modifier.fillMaxSize().padding(horizontal = 28.dp, vertical = 36.dp),
        )
        if (settings.showsBarcodeValue) {
            Text(
                text = code,
                color = foreground,
                fontFamily = FontFamily.Monospace,
                style = MaterialTheme.typography.labelLarge,
                modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 12.dp),
            )
        }
    }
}

@Composable
private fun Barcode(value: String, color: Color, modifier: Modifier) {
    Canvas(modifier) {
        val (bars, totalWidth) = Code39.bars(value)
        val unit = size.width / totalWidth
        bars.forEach { bar ->
            drawRect(color, Offset(bar.startsAt * unit, 0f), androidx.compose.ui.geometry.Size(bar.width * unit, size.height))
        }
    }
}

@Composable
private fun CatDecoration(color: Color, modifier: Modifier) {
    Canvas(modifier.size(64.dp)) {
        drawCat(color)
    }
}

private fun DrawScope.drawCat(color: Color) {
    drawCircle(color, radius = size.minDimension * 0.31f, center = Offset(size.width * 0.5f, size.height * 0.57f))
    val path = androidx.compose.ui.graphics.Path().apply {
        moveTo(size.width * 0.22f, size.height * 0.42f)
        lineTo(size.width * 0.25f, size.height * 0.10f)
        lineTo(size.width * 0.43f, size.height * 0.34f)
        lineTo(size.width * 0.57f, size.height * 0.34f)
        lineTo(size.width * 0.75f, size.height * 0.10f)
        lineTo(size.width * 0.78f, size.height * 0.42f)
        close()
    }
    drawPath(path, color)
}
