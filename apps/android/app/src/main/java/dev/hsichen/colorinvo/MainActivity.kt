package dev.hsichen.colorinvo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia
import androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia.ImageOnly
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.PhotoLibrary
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import dev.hsichen.colorinvo.data.Decoration
import dev.hsichen.colorinvo.ui.CarrierEditorState
import dev.hsichen.colorinvo.ui.CarrierEditorViewModel
import dev.hsichen.colorinvo.ui.CarrierPreview
import dev.hsichen.colorinvo.ui.ColorInvoTheme
import dev.hsichen.colorinvo.ui.Success
import dev.hsichen.colorinvo.ui.Warning

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent { ColorInvoTheme { CarrierEditorScreen() } }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun CarrierEditorScreen(model: CarrierEditorViewModel = viewModel()) {
    val state by model.state
    val photoPicker = rememberLauncherForActivityResult(PickVisualMedia()) { uri ->
        uri?.let(model::loadWallpaper)
    }
    Scaffold(containerColor = MaterialTheme.colorScheme.background) { insets ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(insets)
                .verticalScroll(rememberScrollState())
                .imePadding()
                .padding(horizontal = 24.dp, vertical = 20.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp),
        ) {
            SectionHeader(stringResource(R.string.widget_title), if (state.isSaving) stringResource(R.string.saving) else stringResource(R.string.synced), !state.isSaving)
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Decoration.entries.forEach { decoration ->
                    FilterChip(
                        selected = state.settings.decoration == decoration,
                        onClick = { model.setDecoration(decoration) },
                        label = { Text(stringResource(decoration.label)) },
                        modifier = Modifier.testTag("decoration-${decoration.name.lowercase()}"),
                    )
                }
            }
            Card(
                shape = RoundedCornerShape(24.dp),
                elevation = CardDefaults.cardElevation(8.dp),
                modifier = Modifier.fillMaxWidth().height(196.dp),
            ) { CarrierPreview(state.settings, Modifier.fillMaxSize()) }
            SettingRow(stringResource(R.string.show_carrier_value)) {
                Switch(
                    checked = state.settings.showsBarcodeValue,
                    onCheckedChange = model::setShowsBarcodeValue,
                    modifier = Modifier.testTag("show-carrier-value"),
                )
            }

            SectionHeader(stringResource(R.string.carrier_title), carrierStatus(state), state.carrierIsValid)
            OutlinedTextField(
                value = state.carrierSuffix,
                onValueChange = model::updateCarrierSuffix,
                leadingIcon = { Text("/", fontFamily = FontFamily.Monospace) },
                placeholder = { Text("ABC1234") },
                singleLine = true,
                isError = state.carrierSuffix.isNotEmpty() && !state.carrierIsValid,
                keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Characters),
                modifier = Modifier.fillMaxWidth().testTag("carrier-code"),
            )

            SectionHeader(
                stringResource(R.string.palette_title),
                stringResource(if (state.settings.palette.meetsCommercialGuidance) R.string.scan_ready else R.string.low_contrast),
                state.settings.palette.meetsCommercialGuidance,
            )
            Button(
                onClick = { photoPicker.launch(PickVisualMediaRequest(ImageOnly)) },
                enabled = !state.isAnalyzingWallpaper,
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primaryContainer, contentColor = MaterialTheme.colorScheme.primary),
                modifier = Modifier.fillMaxWidth().height(48.dp).testTag("import-wallpaper"),
            ) {
                androidx.compose.material3.Icon(Icons.Outlined.PhotoLibrary, null)
                Spacer(Modifier.width(8.dp))
                Text(stringResource(if (state.isAnalyzingWallpaper) R.string.analyzing_wallpaper else R.string.import_wallpaper))
            }
            if (state.wallpaperError) Text(stringResource(R.string.wallpaper_error), color = Warning)
            if (state.wallpaperPalettes.isNotEmpty()) {
                Text(stringResource(R.string.wallpaper_colors), style = MaterialTheme.typography.labelLarge)
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    state.wallpaperPalettes.forEachIndexed { index, palette ->
                        FilterChip(
                            selected = state.settings.palette == palette,
                            onClick = { model.selectPalette(palette) },
                            label = { Text("${index + 1}: ${palette.backgroundColor.hex}") },
                            modifier = Modifier.testTag("wallpaper-palette-$index"),
                        )
                    }
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                ColorField(stringResource(R.string.background_color), state.settings.palette.backgroundColor.hex, model::updateBackgroundColor, Modifier.weight(1f), "background-color")
                ColorField(stringResource(R.string.bar_color), state.settings.palette.barColor.hex, model::updateBarColor, Modifier.weight(1f), "bar-color")
            }
            Text(state.settings.palette.standardMessage, style = MaterialTheme.typography.bodySmall)
            Spacer(Modifier.height(12.dp))
        }
    }
}

@Composable
private fun SectionHeader(title: String, status: String, positive: Boolean) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
        Text(title, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
        Spacer(Modifier.weight(1f))
        Text(status, color = if (positive) Success else Warning, style = MaterialTheme.typography.labelLarge)
    }
}

@Composable
private fun SettingRow(label: String, control: @Composable () -> Unit) {
    Card(colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface), border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant)) {
        Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(label)
            Spacer(Modifier.weight(1f))
            control()
        }
    }
}

@Composable
private fun ColorField(label: String, value: String, onValueChange: (String) -> Unit, modifier: Modifier, tag: String) {
    var draft by remember(value) { mutableStateOf(value) }
    OutlinedTextField(
        value = draft,
        onValueChange = {
            draft = it
            onValueChange(it)
        },
        label = { Text(label) },
        singleLine = true,
        isError = !draft.matches(Regex("#[0-9a-fA-F]{6}")),
        modifier = modifier.testTag(tag),
    )
}

@Composable
private fun carrierStatus(state: CarrierEditorState): String = when {
    state.carrierSuffix.isEmpty() -> ""
    state.carrierIsValid -> stringResource(R.string.valid_format)
    else -> stringResource(R.string.invalid_format)
}

private val Decoration.label: Int
    get() = when (this) {
        Decoration.CAT -> R.string.decoration_cat
        Decoration.WAVE -> R.string.decoration_wave
        Decoration.NONE -> R.string.decoration_none
    }
