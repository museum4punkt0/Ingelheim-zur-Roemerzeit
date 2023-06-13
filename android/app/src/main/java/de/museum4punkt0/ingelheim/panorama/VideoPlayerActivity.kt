package de.museum4punkt0.ingelheim.panorama

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import java.io.File

@UnstableApi
class VideoPlayerActivity : Activity() {

    private lateinit var player: ExoPlayer

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.video_view)
        val playerView = findViewById<PlayerView>(R.id.playerView)

        val playerEventListener = object : Player.Listener {
            override fun onPlaybackStateChanged(playbackState: Int) {
                super.onPlaybackStateChanged(playbackState)

                if (playbackState == Player.STATE_ENDED) {
                    finish()
                }
            }
        }

        player = ExoPlayer.Builder(this).build().also {
            val videoUri = Uri.fromFile(intent.getStringExtra(VIDEO_URL_ARG)?.let { File(it) })
            it.setMediaItem(MediaItem.fromUri(videoUri))
            it.addListener(playerEventListener)
            it.prepare()
        }
        playerView.player = player
    }

    override fun onResume() {
        super.onResume()
        player.play()
    }

    override fun onPause() {
        super.onPause()
        player.pause()
    }

    override fun onDestroy() {
        player.release()
        super.onDestroy()
    }

    companion object {
        private const val VIDEO_URL_ARG = "videoUrl"

        fun newInstance(
            context: Context,
            url: String,
        ) = Intent(context, VideoPlayerActivity::class.java).apply {
            putExtra(VIDEO_URL_ARG, url)
        }
    }
}
