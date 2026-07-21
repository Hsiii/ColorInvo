package dev.hsichen.colorinvo.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class Code39Test {
    @Test fun includesStartAndStopSymbols() {
        val (bars, width) = Code39.bars("/ABC1234")
        assertTrue(bars.isNotEmpty())
        assertTrue(width > 0)
        assertEquals(0, bars.first().startsAt)
    }

    @Test(expected = IllegalArgumentException::class)
    fun rejectsUnsupportedCharacters() {
        Code39.bars("_")
    }
}
