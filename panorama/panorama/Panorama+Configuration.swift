import UIKit

public extension Panorama {
    struct Configuration {
        let imageFilename: String
        let accentColor: UIColor
        let hotspots: [Panorama.ImageHotspot]

        public init(
            imageFilename: String,
            accentColor: UIColor,
            hotspots: [Panorama.ImageHotspot]
        ) {
            self.imageFilename = imageFilename
            self.accentColor = accentColor
            self.hotspots = hotspots
        }
    }
}
