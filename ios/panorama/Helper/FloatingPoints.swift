import Foundation

extension FloatingPoint {
    func toDegrees() -> Self {
        return self * 180 / .pi
    }

    func toRadians() -> Self {
        return self * .pi / 180
    }
}
