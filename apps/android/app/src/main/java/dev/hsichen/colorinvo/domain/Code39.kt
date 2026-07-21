package dev.hsichen.colorinvo.domain

object Code39 {
    private val patterns = mapOf(
        '0' to "nnnwwnwnn", '1' to "wnnwnnnnw", '2' to "nnwwnnnnw", '3' to "wnwwnnnnn",
        '4' to "nnnwwnnnw", '5' to "wnnwwnnnn", '6' to "nnwwwnnnn", '7' to "nnnwnnwnw",
        '8' to "wnnwnnwnn", '9' to "nnwwnnwnn", 'A' to "wnnnnwnnw", 'B' to "nnwnnwnnw",
        'C' to "wnwnnwnnn", 'D' to "nnnnwwnnw", 'E' to "wnnnwwnnn", 'F' to "nnwnwwnnn",
        'G' to "nnnnnwwnw", 'H' to "wnnnnwwnn", 'I' to "nnwnnwwnn", 'J' to "nnnnwwwnn",
        'K' to "wnnnnnnww", 'L' to "nnwnnnnww", 'M' to "wnwnnnnwn", 'N' to "nnnnwnnww",
        'O' to "wnnnwnnwn", 'P' to "nnwnwnnwn", 'Q' to "nnnnnnwww", 'R' to "wnnnnnwwn",
        'S' to "nnwnnnwwn", 'T' to "nnnnwnwwn", 'U' to "wwnnnnnnw", 'V' to "nwwnnnnnw",
        'W' to "wwwnnnnnn", 'X' to "nwnnwnnnw", 'Y' to "wwnnwnnnn", 'Z' to "nwwnwnnnn",
        '-' to "nwnnnnwnw", '.' to "wwnnnnwnn", ' ' to "nwwnnnwnn", '+' to "nwnnnwnwn",
        '/' to "nwnwnnnwn", '%' to "nnnwnwnwn", '*' to "nwnnwnwnn",
    )

    data class Bar(val startsAt: Int, val width: Int)

    fun bars(value: String): Pair<List<Bar>, Int> {
        val encoded = "*${value.uppercase()}*"
        val bars = mutableListOf<Bar>()
        var cursor = 0
        encoded.forEachIndexed { characterIndex, character ->
            val pattern = requireNotNull(patterns[character]) { "Unsupported Code 39 character: $character" }
            pattern.forEachIndexed { index, widthCode ->
                val width = if (widthCode == 'w') 3 else 1
                if (index % 2 == 0) bars += Bar(cursor, width)
                cursor += width
            }
            if (characterIndex < encoded.lastIndex) cursor += 1
        }
        return bars to cursor
    }
}
