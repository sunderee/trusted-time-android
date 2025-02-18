package com.peteraleksanderbizjak.trusted_time_android

import android.app.Activity
import com.google.android.gms.time.TrustedTime
import com.google.android.gms.time.TrustedTimeClient
import com.google.android.gms.time.trustedtime.TimeSignal
import com.google.android.gms.time.trustedtime.TimeSignalCurrentInstant
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.*
import org.junit.After
import org.junit.Before
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class TrustedTimeAndroidPluginTest {
    private lateinit var plugin: TrustedTimeAndroidPlugin
    private lateinit var channel: MethodChannel
    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    private lateinit var activityBinding: ActivityPluginBinding
    private lateinit var activity: Activity
    private lateinit var trustedTimeClient: TrustedTimeClient
    private lateinit var timeSignal: TimeSignal
    private lateinit var currentInstant: TimeSignalCurrentInstant

    @Before
    fun setUp() {
        channel = mockk(relaxed = true)
        flutterPluginBinding = mockk {
            every { binaryMessenger } returns mockk()
        }
        activity = mockk()
        activityBinding = mockk {
            every { this@mockk.activity } returns activity
        }
        trustedTimeClient = mockk()
        timeSignal = mockk()
        currentInstant = mockk()

        mockkStatic(TrustedTime::class)
        every { TrustedTime.createClient(any()) } returns mockk {
            every { addOnCompleteListener(any()) } answers {
                firstArg<(com.google.android.gms.tasks.Task<TrustedTimeClient>) -> Unit>().invoke(
                    mockk {
                        every { isSuccessful } returns true
                        every { result } returns trustedTimeClient
                    }
                )
                this
            }
        }

        plugin = TrustedTimeAndroidPlugin()
        plugin.onAttachedToEngine(flutterPluginBinding)
        plugin.onAttachedToActivity(activityBinding)
    }

    @After
    fun tearDown() {
        plugin.onDetachedFromActivity()
        plugin.onDetachedFromEngine(flutterPluginBinding)
        unmockkAll()
    }

    @Test
    fun `computeCurrentUnixEpochMillis returns null when client returns null`() {
        every { trustedTimeClient.computeCurrentUnixEpochMillis() } returns null

        val call = MethodCall("computeCurrentUnixEpochMillis", null)
        val result = mockk<MethodChannel.Result>(relaxed = true)

        plugin.onMethodCall(call, result)

        verify { result.success(null) }
    }

    @Test
    fun `computeCurrentUnixEpochMillis returns timestamp when available`() {
        val timestamp = 1234567890123L
        every { trustedTimeClient.computeCurrentUnixEpochMillis() } returns timestamp

        val call = MethodCall("computeCurrentUnixEpochMillis", null)
        val result = mockk<MethodChannel.Result>(relaxed = true)

        plugin.onMethodCall(call, result)

        verify { result.success(timestamp) }
    }

    @Test
    fun `getLatestTimeSignal returns null when no signal available`() {
        every { trustedTimeClient.latestTimeSignal } returns null

        val call = MethodCall("getLatestTimeSignal", null)
        val result = mockk<MethodChannel.Result>(relaxed = true)

        plugin.onMethodCall(call, result)

        verify { result.success(null) }
    }

    @Test
    fun `getLatestTimeSignal returns serialized signal when available`() {
        val acquisitionError = 100L
        val estimatedError = 150L
        val timestamp = 1234567890123L

        every { timeSignal.acquisitionEstimatedErrorMillis } returns acquisitionError
        every { timeSignal.computeCurrentInstant() } returns currentInstant
        every { currentInstant.estimatedErrorMillis } returns estimatedError
        every { currentInstant.instantMillis } returns timestamp
        every { trustedTimeClient.latestTimeSignal } returns timeSignal

        val call = MethodCall("getLatestTimeSignal", null)
        val result = mockk<MethodChannel.Result>(relaxed = true)

        plugin.onMethodCall(call, result)

        verify {
            result.success(match {
                it as Map<*, *>
                it["acquisitionEstimatedErrorMillis"] == acquisitionError &&
                (it["currentInstant"] as Map<*, *>)["estimatedErrorMillis"] == estimatedError &&
                (it["currentInstant"] as Map<*, *>)["instantMillis"] == timestamp
            })
        }
    }

    @Test
    fun `getLatestTimeSignal handles null current instant`() {
        val acquisitionError = 100L

        every { timeSignal.acquisitionEstimatedErrorMillis } returns acquisitionError
        every { timeSignal.computeCurrentInstant() } returns null
        every { trustedTimeClient.latestTimeSignal } returns timeSignal

        val call = MethodCall("getLatestTimeSignal", null)
        val result = mockk<MethodChannel.Result>(relaxed = true)

        plugin.onMethodCall(call, result)

        verify {
            result.success(match {
                it as Map<*, *>
                it["acquisitionEstimatedErrorMillis"] == acquisitionError &&
                it["currentInstant"] == null
            })
        }
    }

    @Test
    fun `plugin handles unknown method calls`() {
        val call = MethodCall("unknownMethod", null)
        val result = mockk<MethodChannel.Result>(relaxed = true)

        plugin.onMethodCall(call, result)

        verify { result.notImplemented() }
    }
}
