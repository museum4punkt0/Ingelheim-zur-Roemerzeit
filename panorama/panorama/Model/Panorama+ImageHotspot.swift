import Foundation

extension Panorama {
    public struct ImageHotspot {
        let xPosition: Double
        let yPosistion: Double
        let videoFilename: String

        public init(xPosition: Double, yPosistion: Double, videoFilename: String) {
            self.xPosition = xPosition
            self.yPosistion = yPosistion
            self.videoFilename = videoFilename
        }
    }
}
