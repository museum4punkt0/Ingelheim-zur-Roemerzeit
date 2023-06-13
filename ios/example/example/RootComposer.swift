import UIKit
import panorama
import AVKit

class RootComposer {

    let rootWindow: UIWindow

    init(window: UIWindow) {
        self.rootWindow = window
        let exampleConfiguration = Panorama.Configuration(
            imageFilename: "image",
            accentColor: UIColor.systemRed,
            hotspots: [
                Panorama.Hotspot(xPosition: 0.5, yPosistion: 0.4, videoFilename: "video")
            ]
        )

        let panoramaController = Panorama.Controller(
            configuration: exampleConfiguration
        )
        panoramaController.delegate = self
        window.rootViewController = panoramaController
        window.makeKeyAndVisible()
    }
}

extension RootComposer: PanoramaControllerDelegate {
    func panoramaController(_ controller: panorama.Panorama.Controller, didTapHotspot hotspot: panorama.Panorama.Hotspot) {
        showVideo(filename: hotspot.videoFilename, presenter: controller)

    }

    func showVideo(filename: String, presenter: UIViewController) {
        guard let videoURL = FileManager.default.localURL(for: filename, ofType: "mp4") else {
            let alert = UIAlertController(
                title: "Error",
                message: "Could not find video file with name \(filename)", preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(okAction)
            presenter.present(alert, animated: true)
            return
        }
        let avAsset = AVURLAsset(url: videoURL)
        let avItem = AVPlayerItem(asset: avAsset)
        let player = AVPlayer(playerItem: avItem)
        let playerController = AVPlayerViewController()
        playerController.player = player
        presenter.present(playerController, animated: true) {
            player.play()
        }
    }
}
