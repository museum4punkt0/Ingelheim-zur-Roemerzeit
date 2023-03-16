import UIKit

public extension Panorama {
    class Controller: UIViewController {

        lazy var panoramaView: Panorama.View = {
            let image = UIImage(named: "image")!
            let panoramaView = Panorama.View(image: image)
            return panoramaView
        }()

        public init() {
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override func viewDidLoad() {
            super.viewDidLoad()

            self.view = panoramaView
        }


    }
}
