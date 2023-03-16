import Foundation

extension Panorama {
    public struct Image {
        let filename: String
        let hotspots: [ImageHotspot]

        public init(filename: String, hotspots: [ImageHotspot]) {
            self.filename = filename
            self.hotspots = hotspots
        }
    }
}
