import Foundation

public protocol PanoramaControllerDelegate: AnyObject {
    func panoramaController(_ controller: Panorama.Controller, didTapHotspot hotspot: Panorama.Hotspot)
}
