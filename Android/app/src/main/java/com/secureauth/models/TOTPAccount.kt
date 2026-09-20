package com.secureauth.models

import java.util.UUID

data class TOTPAccount(
    val id: String = UUID.randomUUID().toString(),
    val issuer: String,
    val accountName: String,
    val secret: String,
    val algorithm: String = "SHA1",
    val digits: Int = 6,
    val period: Int = 30
)
