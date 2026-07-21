package dev.hsichen.colorinvo

import android.app.LocaleManager
import android.os.LocaleList
import androidx.compose.ui.test.junit4.v2.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performTextInput
import androidx.test.platform.app.InstrumentationRegistry
import java.io.File
import java.io.FileOutputStream
import org.junit.Rule
import org.junit.Test

class PlayStoreScreenshotTest {
    @get:Rule val composeRule = createAndroidComposeRule<MainActivity>()

    @Test fun captureMainScreen() {
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        val locale = InstrumentationRegistry.getArguments().getString("locale", "en-US")
        instrumentation.targetContext.getSystemService(LocaleManager::class.java).applicationLocales =
            LocaleList.forLanguageTags(locale)
        composeRule.activityRule.scenario.recreate()
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("carrier-code").performTextInput("ABC1234")
        composeRule.waitForIdle()

        val output = File(instrumentation.targetContext.getExternalFilesDir(null), "play-store-$locale.png")
        FileOutputStream(output).use { stream ->
            instrumentation.uiAutomation.takeScreenshot().compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
        }
    }
}
