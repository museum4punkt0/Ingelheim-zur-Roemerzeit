import UIKit

extension UIImage {
    var panoramaType: Panorama.PanoramaType {
        if size.width / size.height == 2 {
            return .spherical
        }
        return .cylindrical
    }
}
