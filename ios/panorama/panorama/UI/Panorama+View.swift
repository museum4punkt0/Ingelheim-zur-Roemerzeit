import UIKit
import SceneKit
import CoreMotion
import ImageIO
import SpriteKit

extension Panorama {
    class View: UIView {

        var onHotspotTap: ((Panorama.Hotspot) -> Void)?
        typealias Tag = Int

        private var image: UIImage? {
            didSet {
                self.panoramaType = image?.panoramaType ?? .cylindrical
            }
        }

        private var panoramaType: PanoramaType = .cylindrical {
            didSet {
                createGeometryNode()
            }
        }

        private var angleOffset: Float = 0 {
            didSet {
                geometryNode?.rotation = SCNQuaternion(0, 1, 0, angleOffset)
            }
        }

        // MARK: Private properties
        private var panSpeed = CGPoint(x: 0.4, y: 0.4)
        private var startAngle: Float = 0
        private var minFoV: CGFloat = 20
        private var defaultFoV: CGFloat = 50
        private var maxFoV: CGFloat = 100
        private let MaxPanGestureRotation: Float = GLKMathDegreesToRadians(360)
        private let radius: CGFloat = 10
        private let motionManager = CMMotionManager()
        private var geometryNode: SCNNode?
        private var prevLocation = CGPoint.zero
        private var prevRotation = CGFloat.zero
        private var prevBounds = CGRect.zero
        private var totalX = Float.zero
        private var totalY = Float.zero
        private var motionPaused = false

        private let scene = SCNScene()

        private lazy var sceneView: SCNView = {
            let sceneView = SCNView()
            sceneView.scene = scene
            sceneView.backgroundColor = self.backgroundColor
            let tap = UITapGestureRecognizer(target: self, action: #selector(sceneViewTapped(_:)))
            sceneView.addGestureRecognizer(tap)
            return sceneView
        }()

        private lazy var cameraNode: SCNNode = {
            let node = SCNNode()
            let camera = SCNCamera()
            node.camera = camera
            return node
        }()

        private lazy var opQueue: OperationQueue = {
            let queue = OperationQueue()
            queue.qualityOfService = .userInteractive
            return queue
        }()

        private lazy var fovHeight: CGFloat = {
            return tan(self.yFov/2 * .pi / 180.0) * 2 * self.radius
        }()

        private var startScale: CGFloat = 0.0

        private var xFov: CGFloat {
            return yFov * self.bounds.width / self.bounds.height
        }

        private var yFov: CGFloat {
            get {
                if #available(iOS 11.0, *) {
                    return cameraNode.camera?.fieldOfView ?? 0
                } else {
                    return CGFloat(cameraNode.camera?.yFov ?? 0)
                }
            }
            set {
                if #available(iOS 11.0, *) {
                    cameraNode.camera?.fieldOfView = newValue
                } else {
                    cameraNode.camera?.yFov = Double(newValue)
                }
            }
        }

        private var hotspotsByIdentifier: [String: Hotspot] = [:]

        // MARK: - inititializer
        init(image: UIImage) {
            super.init(frame: .zero)
            setupSubviews()

            scene.rootNode.addChildNode(cameraNode)
            yFov = defaultFoV

            sceneView.scene = scene
            sceneView.backgroundColor = self.backgroundColor
            setImage(image)
            startMotionUpdates()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit {
            if motionManager.isDeviceMotionActive {
                motionManager.stopDeviceMotionUpdates()
            }
        }

        func setImage(_ image: UIImage) {
            self.image = image
        }
    }
}

private extension Panorama.View {
    func setupSubviews() {
        [sceneView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sceneView.topAnchor.constraint(equalTo: topAnchor),
            sceneView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
  
    func createGeometryNode() {
        guard let image = image else {return}

        geometryNode?.removeFromParentNode()

        let material = SCNMaterial()
        material.diffuse.contents = image
        material.diffuse.mipFilter = .nearest
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, 1, 1)
        material.diffuse.wrapS = .repeat
        material.cullMode = .front

        if panoramaType == .spherical {
            let sphere = SCNSphere(radius: radius)
            sphere.segmentCount = 300
            sphere.firstMaterial = material

            let sphereNode = SCNNode()
            sphereNode.geometry = sphere
            geometryNode = sphereNode
        } else {
            let tube = SCNTube(innerRadius: radius, outerRadius: radius, height: fovHeight)
            tube.heightSegmentCount = 50
            tube.radialSegmentCount = 300
            tube.firstMaterial = material

            let tubeNode = SCNNode()
            tubeNode.geometry = tube
            geometryNode = tubeNode
        }
        geometryNode?.rotation = SCNQuaternion(0, 1, 0, angleOffset)
        scene.rootNode.addChildNode(geometryNode!)
    }

    @objc private func sceneViewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location: CGPoint = sender.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty{
                let tappedNode = hits.first?.node

                if let name = tappedNode?.name, let hotspot = hotspotsByIdentifier[name] {
                    onHotspotTap?(hotspot)
                }
            }
        }
    }

    func startMotionUpdates(){

        guard motionManager.isDeviceMotionAvailable else {return}
        motionManager.deviceMotionUpdateInterval = 0.015

        motionPaused = false
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical, to: opQueue,
            withHandler: { [weak self] (motionData, error) in
                guard let panoramaView = self else {return}
                guard !panoramaView.motionPaused else {return}

                guard let motionData = motionData else {
                    print("\(String(describing: error?.localizedDescription))")
                    panoramaView.motionManager.stopDeviceMotionUpdates()
                    return
                }

                DispatchQueue.main.async {
                    if panoramaView.panoramaType == .cylindrical {

                        let rotationMatrix = motionData.attitude.rotationMatrix
                        var userHeading = .pi - atan2(rotationMatrix.m32, rotationMatrix.m31)
                        userHeading += .pi/2

                        var startAngle = panoramaView.startAngle
                        startAngle += panoramaView.totalY

                        // Prevent vertical movement in a cylindrical panorama
                        panoramaView.cameraNode.eulerAngles = SCNVector3Make(0, startAngle + Float(-userHeading), 0)

                    } else {
                        // Use quaternions when in spherical mode to prevent gimbal lock
                        //panoramaView.cameraNode.orientation = motionData.orientation()
                        var orientation = motionData.orientation()

                        // Represent the orientation as a GLKQuaternion

                        // same code as pan rotation
                        // but with our total accumulated
                        // movements
                        var glQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)

                        let xMultiplier = GLKQuaternionMakeWithAngleAndAxis(panoramaView.totalX, 1, 0, 0)
                        glQuaternion = GLKQuaternionMultiply(glQuaternion, xMultiplier)

                        let yMultiplier = GLKQuaternionMakeWithAngleAndAxis(panoramaView.totalY, 0, 1, 0)
                        glQuaternion = GLKQuaternionMultiply(yMultiplier, glQuaternion)

                        orientation = SCNQuaternion(x: glQuaternion.x, y: glQuaternion.y, z: glQuaternion.z, w: glQuaternion.w)
                        panoramaView.cameraNode.orientation = orientation

                    }
                }
            }
        )
    }
}

// MARK: - hotspot support
extension Panorama.View {
    func addHotspots(_ hotspots: [Panorama.Hotspot], color: UIColor) {
        hotspots.enumerated().forEach { index, hotspot in
            addHotspot(hotspot, tag: index, color: color)
        }
    }

    private func addHotspot(_ hotspot: Panorama.Hotspot, tag: Tag, color: UIColor) {
        let hotspotNode = createHotspotNode(hotspot, tag: tag, color: color)
        let identifier = UUID().description
        hotspotNode.name = identifier
        geometryNode?.addChildNode(hotspotNode)
        self.hotspotsByIdentifier[identifier] = hotspot
    }

    private func createHotspotNode(_ hotspot: Panorama.Hotspot, tag: Tag, color: UIColor) -> SCNNode {
        let radius: Double = 10

        let button = Panorama.HotspotButton(
            configuration: .init(backgroundColor: color, tintColor: .white),
            frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        )
        button.tag = tag
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let videoImage = UIImage(systemName: "play.fill", withConfiguration: config)
        button.setImage(videoImage, for: [])
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
}

