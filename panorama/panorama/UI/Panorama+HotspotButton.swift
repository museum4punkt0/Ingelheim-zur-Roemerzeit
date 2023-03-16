import UIKit

extension Panorama {
    class HotspotButton: UIButton{
        init(configuration: Configuration, frame: CGRect) {
            super.init(frame: frame)

            self.backgroundColor = configuration.backgroundColor
            self.tintColor = configuration.tintColor
            layer.borderColor = configuration.tintColor.cgColor
            layer.borderWidth = 1
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        struct Configuration {
            let backgroundColor: UIColor
            let tintColor: UIColor
        }
    }
}
