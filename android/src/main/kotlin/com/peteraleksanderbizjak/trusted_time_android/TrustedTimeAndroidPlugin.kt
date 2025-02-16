package com.peteraleksanderbizjak.trusted_time_android

import android.util.Log
import com.google.android.gms.time.TrustedTime
import com.google.android.gms.time.TrustedTimeClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

internal class TrustedTimeAndroidPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var trustedTimeClient: TrustedTimeClient? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        TrustedTime.createClient(binding.activity)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    Log.d(LOG_TAG, "TrustedTime client created successfully")
                    trustedTimeClient = task.result
                } else {
                    Log.w(LOG_TAG, "TruestTime client not created: ${task.exception}")
                }
            }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TrustedTime.createClient(binding.activity)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    Log.d(LOG_TAG, "TrustedTime client created successfully")
                    trustedTimeClient = task.result
                } else {
                    Log.w(LOG_TAG, "TruestTime client not created: ${task.exception}")
                }
            }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        trustedTimeClient?.dispose()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        trustedTimeClient?.dispose()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(LOG_TAG, "Calling method: ${call.method}")

        when (call.method) {
            METHOD_COMPUTE_CURRENT_UNIX_EPOCH_MILLIS -> {
                val currentUnixEpochMillis = trustedTimeClient
                    ?.computeCurrentUnixEpochMillis()
                result.success(currentUnixEpochMillis)
            }

            METHOD_GET_LATEST_TIME_SIGNAL -> {
                val serializedLatestTimeSignal = trustedTimeClient?.latestTimeSignal
                    ?.toSerializable()
                    ?.toMap()
                result.success(serializedLatestTimeSignal)
            }

            else -> result.notImplemented()
        }
    }

    companion object {
        private val LOG_TAG = TrustedTimeAndroidPlugin::class.java.name

        private const val CHANNEL_NAME = "trusted_time_android"
        private const val METHOD_COMPUTE_CURRENT_UNIX_EPOCH_MILLIS = "computeCurrentUnixEpochMillis"
        private const val METHOD_GET_LATEST_TIME_SIGNAL = "getLatestTimeSignal"
    }
}
