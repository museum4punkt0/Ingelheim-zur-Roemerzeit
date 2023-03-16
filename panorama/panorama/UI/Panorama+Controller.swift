import UIKit
import SceneKit

public extension Panorama {
    class Controller: UIViewController {

        typealias Tag = Int

        let configuration: Configuration
        let accentColor: UIColor = UIColor.systemRed

        private var hotspotNodes: [Tag: Panorama.ImageHotspot] = [:]

        lazy var panoramaView: Panorama.View = {
            let image = UIImage(named: "image")!
            let panoramaView = Panorama.View(image: image)
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

            configuration.hotspots.enumerated().forEach { index, hotspot in
                addHotspot(hotspot: hotspot, tag: index)
            }
        }
    }
}

private extension Panorama.Controller {

    func addHotspot(hotspot: Panorama.ImageHotspot, tag: Tag) {
        let hotspotNode = createHotspotNode(hotspot, tag: tag)
        panoramaView.addHotspotNode(hotspotNode)
        self.hotspotNodes[tag] = hotspot
    }

    func createHotspotNode(_ hotspot: Panorama.ImageHotspot, tag: Tag) -> SCNNode {
        let radius: Double = 10

        let button = Panorama.HotspotButton(
            configuration: .init(backgroundColor: accentColor, tintColor: .white),
            frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        )
        button.tag = tag
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let videoImage = UIImage(systemName: "play.fill", withConfiguration: config)
        button.setImage(videoImage, for: [])

        button.addTarget(self, action: #selector(didPressHotpspotButton(_:)), for: .touchUpInside)
        let material = SCNMaterial()

        let size: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 5 : 3.5
        let hotspotGeometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0.8)
        let hotspotNode = SCNNode(geometry: hotspotGeometry)
        hotspotNode.scale = SCNVector3(0.2, 0.2, 0.2)
         material.diffuse.contents = button
        hotspotNode.geometry?.materials = [material]

        // set hotspot's axes equal to camera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [.X, .Y, .Z]
        hotspotNode.constraints = [billboardConstraint]

        // set hotspot position
        let imageCoordinates = ImageCoordinates(x: hotspot.xPosition, y: hotspot.yPosistion)
        let position = imageCoordinates.positionVector(radius: radius)
        hotspotNode.position = position

        return hotspotNode
    }

    @objc private func didPressHotpspotButton(_ sender: UIButton) {

     //   guard let hotspot = hotspots[sender.tag] else { return }
        //  viewDelegate?.panoramaView(self, didSelecHotspot: hotspot)
    }

}
