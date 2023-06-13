package de.museum4punkt0.ingelheim.panorama.data

import android.content.Context
import android.graphics.Bitmap
import androidx.core.graphics.drawable.toBitmap
import com.panoramagl.PLConstants
import com.panoramagl.PLImage
import com.panoramagl.hotspots.ActionPLHotspot
import com.panoramagl.hotspots.HotSpotListener
import de.museum4punkt0.ingelheim.panorama.R

class HotspotMapper {

    fun mapToPlHotspot(
        context: Context,
        hotspot: Hotspot,
        hotspotListener: HotSpotListener,
    ): ActionPLHotspot {
        val bitmap: Bitmap = context.getDrawable(
            R.drawable.ic_hotspot_video
        )?.toBitmap() ?: throw Exception("Creating hotspot bitmap failed.")

        return ActionPLHotspot(
            hotspotListener,
            hotspot.id.toLong(),
            PLImage(bitmap),
            90 - (180 * hotspot.y), // Vertical position in degrees [-90.0, 90.0] (down to up)
            (360 * hotspot.x) - 180, // Horizontal position in degrees [-180.0, 180.0] (left to right)
            PLConstants.kDefaultHotspotSize, // Width (panorama's diameter at percentage) [0.0, 1.0] e.g. 0.05 is the 5%
            PLConstants.kDefaultHotspotSize, // Height (panorama's diameter at percentage) [0.0, 1.0] e.g. 0.05 is the 5%
        )
    }
}
