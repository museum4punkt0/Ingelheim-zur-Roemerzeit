package de.museum4punkt0.ingelheim.panorama.data

object HotspotRepository {

    val hotspots = listOf(
        Hotspot(
            id = "1",
            x = 0.5f,
            y = 0.4f,
            url = "//android_asset/video.mp4",
        )
    )

    fun getHotspot(id: String): Hotspot? = hotspots.firstOrNull { id == it.id }
}
