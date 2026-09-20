package com.secureauth.ui

import android.app.Activity
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.secureauth.services.AccountManager
import com.secureauth.ui.screens.AccountListScreen
import com.secureauth.ui.screens.BiometricAuthScreen

@Composable
fun SecureAuthApp() {
    val context = LocalContext.current
    val activity = context as? Activity
    val accountManager = remember { AccountManager.getInstance(context) }
    var isAuthenticated by remember { mutableStateOf(false) }

    Scaffold { paddingValues ->
        if (isAuthenticated) {
            AccountListScreen(
                accountManager = accountManager,
                modifier = Modifier.padding(paddingValues)
            )
        } else {
            BiometricAuthScreen(
                onAuthenticated = { isAuthenticated = true },
                activity = activity,
                modifier = Modifier.padding(paddingValues)
            )
        }
    }
}
