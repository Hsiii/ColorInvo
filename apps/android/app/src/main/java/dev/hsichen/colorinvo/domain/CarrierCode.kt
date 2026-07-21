package dev.hsichen.colorinvo.domain

object CarrierCode {
    private val pattern = Regex("^/[0-9A-Z+\\-.]{7}$")

    fun normalize(rawValue: String): String = rawValue.trim().uppercase()

    fun fromSuffix(rawValue: String): String {
        val suffix = normalize(rawValue).replace("/", "").take(7)
        return if (suffix.isEmpty()) "" else "/$suffix"
    }

    fun isValid(rawValue: String): Boolean = pattern.matches(normalize(rawValue))
}
