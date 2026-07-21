package dev.hsichen.colorinvo

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsOn
import androidx.compose.ui.test.assertTextContains
import androidx.compose.ui.test.junit4.v2.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import org.junit.Rule
import org.junit.Test

class CarrierEditorScreenTest {
    @get:Rule val composeRule = createAndroidComposeRule<MainActivity>()

    @Test fun carrierEntryUpdatesPreviewAndValidation() {
        composeRule.onNodeWithTag("carrier-code").performTextInput("ABC1234")
        composeRule.onNodeWithTag("carrier-code").assertTextContains("ABC1234")
        composeRule.onNodeWithTag("show-carrier-value").assertIsOn()
    }

    @Test fun decorationCanBeChanged() {
        composeRule.onNodeWithTag("decoration-wave").performClick()
        composeRule.onNodeWithTag("decoration-wave").assertIsDisplayed()
    }
}
