package com.secureauth.services

import android.app.assist.AssistStructure
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.Dataset
import android.service.autofill.FillCallback
import android.service.autofill.FillContext
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveRequest
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import com.secureauth.R

class SecureAuthAutofillService : AutofillService() {

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        val context = request.fillContexts
        val structure = context.last().structure

        val autofillFields = findAutofillFields(structure)

        if (autofillFields.isEmpty()) {
            callback.onSuccess(null)
            return
        }

        val accountManager = AccountManager.getInstance(applicationContext)
        val codes = accountManager.getAllCodes()

        if (codes.isEmpty()) {
            callback.onSuccess(null)
            return
        }

        val responseBuilder = FillResponse.Builder()

        autofillFields.forEach { fieldId ->
            codes.forEach { (accountLabel, code) ->
                val remoteViews = RemoteViews(packageName, android.R.layout.simple_list_item_1).apply {
                    setTextViewText(android.R.id.text1, "$accountLabel - $code")
                }

                val dataset = Dataset.Builder()
                    .setValue(fieldId, AutofillValue.forText(code), remoteViews)
                    .build()

                responseBuilder.addDataset(dataset)
            }
        }

        callback.onSuccess(responseBuilder.build())
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        callback.onSuccess()
    }

    private fun findAutofillFields(structure: AssistStructure): List<AutofillId> {
        val fields = mutableListOf<AutofillId>()

        fun traverseNode(node: AssistStructure.ViewNode) {
            val hints = node.autofillHints
            if (hints != null) {
                for (hint in hints) {
                    if (hint == "oneTimeCode" || hint == "smsOTPCode" ||
                        hint.contains("otp", ignoreCase = true) ||
                        hint.contains("code", ignoreCase = true) ||
                        hint.contains("verification", ignoreCase = true)) {
                        node.autofillId?.let { fields.add(it) }
                        break
                    }
                }
            }

            val inputType = node.inputType
            if (inputType != 0) {
                val text = node.text?.toString() ?: ""
                val hint = node.hint?.toString() ?: ""

                if (text.matches(Regex("\\d{6}")) ||
                    hint.contains("code", ignoreCase = true) ||
                    hint.contains("otp", ignoreCase = true) ||
                    hint.contains("verification", ignoreCase = true)) {
                    node.autofillId?.let { fields.add(it) }
                }
            }

            for (i in 0 until node.childCount) {
                traverseNode(node.getChildAt(i))
            }
        }

        for (i in 0 until structure.windowNodeCount) {
            traverseNode(structure.getWindowNodeAt(i).rootViewNode)
        }

        return fields
    }
}
