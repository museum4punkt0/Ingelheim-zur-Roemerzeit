import Foundation
import AVKit

extension FileManager {
    func localURL(for filename: String, ofType: String) -> URL? {
        let cacheDirectory = self.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(filename).\(ofType)")

        guard self.fileExists(atPath: url.path) else {
            guard let video = NSDataAsset(name: filename)  else { return nil }
            self.createFile(atPath: url.path, contents: video.data, attributes: nil)
            return url
        }
        return url
    }
}
