import Foundation
import SceneKit

struct ImageCoordinates: Equatable, Hashable, Codable {
    public let x: Double
    public let y: Double

    /// Convert the image coordinates between 0...1 to an angle between -π and π longitude
    /// and a latitude between π/2 and -π/2 (where the positive angle is above the equator)
    ///
    /// ```
    ///        0                 1             -π                 π
    ///      0 ┌──────────────────┐         π/2 ┌──────────────────┐
    ///        │                  │             │                  │
    ///        │                  │   ==>       │                  │
    ///        │                  │             │                  │
    ///      1 └──────────────────┘        -π/2 └──────────────────┘
    /// ```
    ///
    /// - Returns: A tuple of `phi` longitude and `theta` latitude
    internal func toSpherical() -> (phi: Double, theta: Double) {
        let sphereX: Double = -1 * (x * 2 * .pi - .pi)
        let sphereY: Double = -1 * (y * .pi - .pi/2)
        return (sphereX, sphereY)
    }

    /// Get a position vector for a given radius
    /// - Parameter r: The radius of the sphere to map to
    /// - Returns: A vector poionting to the image's coordinates
    public func positionVector(radius r: Double) -> SCNVector3 {
        let angles = toSpherical()
        let x: Double = r * sin(angles.phi) * cos(angles.theta)
        let y: Double = r * sin(angles.theta)
        let z: Double = r * cos(angles.phi) * cos(angles.theta)
        return .init(x, y, z)
    }
}
