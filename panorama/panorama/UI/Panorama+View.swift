import UIKit
import SceneKit
import CoreMotion
import ImageIO
import SpriteKit

extension Panorama {
    class View: UIView {

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

        func addHotspotNode(_ hotspotNode: SCNNode) {
            geometryNode?.addChildNode(hotspotNode)
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

