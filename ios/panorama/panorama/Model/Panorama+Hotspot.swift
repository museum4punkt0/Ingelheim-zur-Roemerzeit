import Foundation

extension Panorama {
    public struct Hotspot {
        public let xPosition: Double
        public let yPosistion: Double
        public let videoFilename: String

        public init(xPosition: Double, yPosistion: Double, videoFilename: String) {
            self.xPosition = xPosition
            self.yPosistion = yPosistion
            self.videoFilename = videoFilename
        }
    }
}
