package dev.hsichen.colorinvo.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CarrierCodeTest {
    @Test fun normalizesCarrierInput() {
        assertEquals("/ABC1234", CarrierCode.fromSuffix(" abc1234 "))
    }

    @Test fun acceptsTaiwanCarrierAlphabet() {
        assertTrue(CarrierCode.isValid("/A1+-.Z9"))
    }

    @Test fun rejectsWrongLengthAndUnsupportedCharacters() {
        assertFalse(CarrierCode.isValid("/ABC123"))
        assertFalse(CarrierCode.isValid("/ABC_123"))
    }
}
