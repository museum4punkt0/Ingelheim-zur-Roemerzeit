package de.museum4punkt0.ingelheim.panorama

import android.app.Activity
import android.hardware.SensorManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.widget.Toast
import com.panoramagl.PLImage
import com.panoramagl.PLManager
import com.panoramagl.PLSphericalPanorama
import com.panoramagl.hotspots.HotSpotListener
import com.panoramagl.utils.PLUtils
import de.museum4punkt0.ingelheim.panorama.data.HotspotMapper
import de.museum4punkt0.ingelheim.panorama.data.HotspotRepository
import de.museum4punkt0.ingelheim.panorama.panorama.FutureOrientationProvider
import de.museum4punkt0.ingelheim.panorama.panorama.OrientationProvider

class PanoramaActivity : Activity(), HotSpotListener {

    private lateinit var plManager: PLManager
    private lateinit var orientationProvider: FutureOrientationProvider

    private val hotspots get() = HotspotRepository.hotspots

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.panorama_view)

        initializeOrientationProvider()

        plManager = PLManager(this)
        plManager.setContentView(findViewById(android.R.id.content))
        plManager.onCreate()

        val panorama = PLSphericalPanorama()
        panorama.camera.setFovRange(15f, 45f)

        Handler(Looper.getMainLooper()).postDelayed(
            {
                panorama.setImage(
                    PLImage(PLUtils.getBitmap(this, R.drawable.panorama), false)
                )
                hotspots.forEach {
                    panorama.addHotspot(
                        HotspotMapper().mapToPlHotspot(this, it, this)
                    )
                }

                panorama.camera.lookAtAndZoomFactor(
                    orientationProvider.pitch * -1,
                    orientationProvider.azimuth,
                    0.5f,
                    false
                )
                plManager.panorama = panorama
                plManager.startSensorialRotation()
                orientationProvider.stop()
            },
            250
        )
    }

    private fun initializeOrientationProvider() {
        val listener = object : OrientationProvider.ICallback {
            override fun onOrientationChanged(orientationDegrees: FloatArray) = Unit

            override fun onNoSensorFound() {
                Toast.makeText(
                    this@PanoramaActivity,
                    "No compass or gyroscope found",
                    Toast.LENGTH_LONG
                ).show()
            }

            override fun onAccuracyChanged(accuracy: Int) = Unit
        }
        orientationProvider = FutureOrientationProvider(
            this,
            OrientationProvider.MODE.LOOK_THROUGH,
            getSystemService(SENSOR_SERVICE) as SensorManager,
            listener
        )
    }

    override fun onResume() {
        super.onResume()
        orientationProvider.start()
        plManager.onResume()
    }

    override fun onPause() {
        orientationProvider.stop()
        plManager.onPause()
        super.onPause()
    }

    override fun onDestroy() {
        plManager.onDestroy()
        super.onDestroy()
    }

    override fun onTouchEvent(event: MotionEvent): Boolean = plManager.onTouchEvent(event)

    override fun onHotspotClick(identifier: Long) {
        HotspotRepository.getHotspot(id = identifier.toString())?.let { hotspot ->
            startActivity(
                VideoPlayerActivity.newInstance(
                    context = this,
                    url = hotspot.url,
                )
            )
        }
    }
}
