package com.example.smart_expense

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.example.smart_expense/sms"
        private const val PERMISSION_REQUEST_CODE = 1010

        private var methodChannel: MethodChannel? = null

        fun onSmsReceived(sender: String, body: String, timestamp: Long) {
            val data = mapOf(
                "sender" to sender,
                "body" to body,
                "timestamp" to timestamp
            )
            methodChannel?.invokeMethod("onSmsReceived", data)
        }
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        methodChannel = channel
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        methodChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPermissions" -> {
                val hasReceive = ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
                val hasRead = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED

                if (hasReceive && hasRead) {
                    result.success(true)
                } else {
                    pendingPermissionResult = result
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
                        PERMISSION_REQUEST_CODE
                    )
                }
            }
            "hasPermissions" -> {
                val hasReceive = ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
                val hasRead = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                result.success(hasReceive && hasRead)
            }
            "getInboxSms" -> {
                val count = call.argument<Int>("count") ?: 15
                getInboxMessages(count, result)
            }
            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    private fun getInboxMessages(limit: Int, result: MethodChannel.Result) {
        val hasRead = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
        if (!hasRead) {
            result.error("PERMISSION_DENIED", "READ_SMS permission not granted", null)
            return
        }

        try {
            val uri = Uri.parse("content://sms/inbox")
            val projection = arrayOf("address", "body", "date")
            val cursor: Cursor? = contentResolver.query(
                uri,
                projection,
                null,
                null,
                "date DESC"
            )

            val messages = mutableListOf<Map<String, Any>>()
            cursor?.use {
                val addressIdx = it.getColumnIndex("address")
                val bodyIdx = it.getColumnIndex("body")
                val dateIdx = it.getColumnIndex("date")

                var count = 0
                while (it.moveToNext() && count < limit) {
                    val address = if (addressIdx != -1) it.getString(addressIdx) ?: "" else ""
                    val body = if (bodyIdx != -1) it.getString(bodyIdx) ?: "" else ""
                    val date = if (dateIdx != -1) it.getLong(dateIdx) else System.currentTimeMillis()

                    messages.add(
                        mapOf(
                            "sender" to address,
                            "body" to body,
                            "timestamp" to date
                        )
                    )
                    count++
                }
            }

            result.success(messages)
        } catch (e: Exception) {
            result.error("SMS_QUERY_FAILED", e.message, null)
        }
    }
}
