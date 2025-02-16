package com.peteraleksanderbizjak.trusted_time_android

import com.google.android.gms.time.trustedtime.TimeSignal

internal data class SerializableTimeSignal(
    val acquisitionEstimatedErrorMillis: Long,
    val currentInstant: SerializableCurrentInstant?
)

internal data class SerializableCurrentInstant(
    val estimatedErrorMillis: Long?,
    val instantMillis: Long?
)

internal fun TimeSignal.toSerializable(): SerializableTimeSignal {
    return SerializableTimeSignal(
        acquisitionEstimatedErrorMillis = this.acquisitionEstimatedErrorMillis,
        currentInstant = this.computeCurrentInstant()?.let {
            SerializableCurrentInstant(
                estimatedErrorMillis = it.estimatedErrorMillis,
                instantMillis = it.instantMillis
            )
        }
    )
}

internal fun SerializableTimeSignal.toMap(): Map<String, Any?> = mapOf(
    "acquisitionEstimatedErrorMillis" to this.acquisitionEstimatedErrorMillis,
    "currentInstant" to this.currentInstant?.toMap()
)

internal fun SerializableCurrentInstant.toMap(): Map<String, Any?> = mapOf(
    "estimatedErrorMillis" to this.estimatedErrorMillis,
    "instantMillis" to this.instantMillis
)