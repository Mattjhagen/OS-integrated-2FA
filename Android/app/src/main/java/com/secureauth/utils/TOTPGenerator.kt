package com.secureauth.utils

import android.net.Uri
import com.secureauth.models.TOTPAccount
import java.nio.ByteBuffer
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
import kotlin.math.pow

object TOTPGenerator {
    fun generateCode(
        secret: String,
        time: Long = System.currentTimeMillis() / 1000,
        digits: Int = 6,
        period: Int = 30
    ): String {
        val secretBytes = base32Decode(secret) ?: return "------"
        val counter = time / period

        val buffer = ByteBuffer.allocate(8)
        buffer.putLong(counter)
        val counterBytes = buffer.array()

        val mac = Mac.getInstance("HmacSHA1")
        val keySpec = SecretKeySpec(secretBytes, "HmacSHA1")
        mac.init(keySpec)
        val hash = mac.doFinal(counterBytes)

        val offset = hash[hash.size - 1].toInt() and 0x0f
        val truncatedHash = hash.copyOfRange(offset, offset + 4)

        val value = ByteBuffer.wrap(truncatedHash).int and 0x7fffffff
        val otp = value % 10.0.pow(digits).toInt()

        return otp.toString().padStart(digits, '0')
    }

    private fun base32Decode(input: String): ByteArray? {
        val base32Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        val cleanInput = input.uppercase().replace(" ", "").replace("=", "")

        var bits = ""
        for (char in cleanInput) {
            val index = base32Chars.indexOf(char)
            if (index == -1) return null
            bits += index.toString(2).padStart(5, '0')
        }

        val bytes = mutableListOf<Byte>()
        for (i in 0 until bits.length step 8) {
            if (i + 8 <= bits.length) {
                val byte = bits.substring(i, i + 8).toInt(2).toByte()
                bytes.add(byte)
            }
        }

        return bytes.toByteArray()
    }

    fun parseOTPAuthURL(url: String): TOTPAccount? {
        val uri = Uri.parse(url)

        if (uri.scheme != "otpauth" || uri.host != "totp") {
            return null
        }

        val secret = uri.getQueryParameter("secret") ?: return null
        val path = uri.path?.trim('/') ?: return null
        val components = path.split(":")

        val issuer = uri.getQueryParameter("issuer") ?: components.getOrNull(0) ?: "Unknown"
        val accountName = components.getOrNull(1) ?: components.getOrNull(0) ?: ""

        val algorithm = uri.getQueryParameter("algorithm") ?: "SHA1"
        val digits = uri.getQueryParameter("digits")?.toIntOrNull() ?: 6
        val period = uri.getQueryParameter("period")?.toIntOrNull() ?: 30

        return TOTPAccount(
            issuer = issuer,
            accountName = accountName,
            secret = secret,
            algorithm = algorithm,
            digits = digits,
            period = period
        )
    }
}
