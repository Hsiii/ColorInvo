package dev.hsichen.colorinvo.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

val Primary = Color(0xFF006780)
val PrimarySoft = Color(0xFFD7F3FF)
val Background = Color(0xFFF7F8FA)
val Surface = Color(0xFFFFFFFF)
val Success = Color(0xFF18794E)
val Warning = Color(0xFF9C5700)

@Composable
fun ColorInvoTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = Primary,
            primaryContainer = PrimarySoft,
            background = Background,
            surface = Surface,
            error = Warning,
        ),
        content = content,
    )
}
