import UIKit
import SceneKit

public extension Panorama {
    class Controller: UIViewController {
        public weak var delegate: PanoramaControllerDelegate?

        let configuration: Configuration
        let accentColor: UIColor = UIColor.systemRed

        lazy var panoramaView: Panorama.View = {
            let image = UIImage(named: "image")!
            let panoramaView = Panorama.View(image: image)
            panoramaView.onHotspotTap = { [unowned self] hotspot in
                delegate?.panoramaController(self, didTapHotspot: hotspot)
            }
            return panoramaView
        }()

        public init(configuration: Panorama.Configuration) {
            self.configuration = configuration
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override func viewDidLoad() {
            super.viewDidLoad()
            self.view = panoramaView
            panoramaView.addHotspots(configuration.hotspots, color: configuration.accentColor)
        }
    }
}

