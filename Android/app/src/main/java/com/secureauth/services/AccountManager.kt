package com.secureauth.services

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.secureauth.models.TOTPAccount
import com.secureauth.utils.TOTPGenerator
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class AccountManager(context: Context) {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val sharedPreferences = EncryptedSharedPreferences.create(
        context,
        "secure_auth_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    private val gson = Gson()
    private val accountsKey = "totp_accounts"

    private val _accounts = MutableStateFlow<List<TOTPAccount>>(emptyList())
    val accounts: StateFlow<List<TOTPAccount>> = _accounts.asStateFlow()

    init {
        loadAccounts()
    }

    private fun loadAccounts() {
        val json = sharedPreferences.getString(accountsKey, null)
        if (json != null) {
            val type = object : TypeToken<List<TOTPAccount>>() {}.type
            _accounts.value = gson.fromJson(json, type)
        }
    }

    fun addAccount(account: TOTPAccount) {
        val updatedAccounts = _accounts.value + account
        _accounts.value = updatedAccounts
        saveAccounts()
    }

    fun deleteAccount(account: TOTPAccount) {
        val updatedAccounts = _accounts.value.filter { it.id != account.id }
        _accounts.value = updatedAccounts
        saveAccounts()
    }

    fun updateAccount(account: TOTPAccount) {
        val updatedAccounts = _accounts.value.map {
            if (it.id == account.id) account else it
        }
        _accounts.value = updatedAccounts
        saveAccounts()
    }

    private fun saveAccounts() {
        val json = gson.toJson(_accounts.value)
        sharedPreferences.edit().putString(accountsKey, json).apply()
    }

    fun getCode(accountId: String): String? {
        val account = _accounts.value.find { it.id == accountId } ?: return null
        return TOTPGenerator.generateCode(
            secret = account.secret,
            digits = account.digits,
            period = account.period
        )
    }

    fun getAllCodes(): Map<String, String> {
        return _accounts.value.associate { account ->
            "${account.issuer}: ${account.accountName}" to TOTPGenerator.generateCode(
                secret = account.secret,
                digits = account.digits,
                period = account.period
            )
        }
    }

    companion object {
        @Volatile
        private var instance: AccountManager? = null

        fun getInstance(context: Context): AccountManager {
            return instance ?: synchronized(this) {
                instance ?: AccountManager(context.applicationContext).also { instance = it }
            }
        }
    }
}
