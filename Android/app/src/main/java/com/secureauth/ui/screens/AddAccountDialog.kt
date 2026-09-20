package com.secureauth.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import com.secureauth.models.TOTPAccount
import com.secureauth.utils.TOTPGenerator

@Composable
fun AddAccountDialog(
    onDismiss: () -> Unit,
    onAccountAdded: (TOTPAccount) -> Unit
) {
    var issuer by remember { mutableStateOf(TextFieldValue("")) }
    var accountName by remember { mutableStateOf(TextFieldValue("")) }
    var secret by remember { mutableStateOf(TextFieldValue("")) }
    var showError by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Account") },
        text = {
            Column {
                OutlinedTextField(
                    value = issuer,
                    onValueChange = { issuer = it },
                    label = { Text("Issuer (e.g., Google, GitHub)") },
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = accountName,
                    onValueChange = { accountName = it },
                    label = { Text("Account (e.g., user@example.com)") },
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = secret,
                    onValueChange = { secret = it },
                    label = { Text("Secret Key") },
                    supportingText = { Text("Base32 encoded secret key") },
                    modifier = Modifier.fillMaxWidth()
                )

                if (showError) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = errorMessage,
                        color = androidx.compose.ui.graphics.Color.Red,
                        modifier = Modifier.padding(8.dp)
                    )
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    val cleanSecret = secret.text.replace(" ", "").uppercase()

                    if (issuer.text.isEmpty() || accountName.text.isEmpty() || cleanSecret.isEmpty()) {
                        errorMessage = "Please fill all fields"
                        showError = true
                        return@Button
                    }

                    if (TOTPGenerator.generateCode(cleanSecret) == "------") {
                        errorMessage = "Invalid secret key"
                        showError = true
                        return@Button
                    }

                    val account = TOTPAccount(
                        issuer = issuer.text,
                        accountName = accountName.text,
                        secret = cleanSecret
                    )
                    onAccountAdded(account)
                },
                enabled = issuer.text.isNotEmpty() &&
                         accountName.text.isNotEmpty() &&
                         secret.text.isNotEmpty()
            ) {
                Text("Add")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
