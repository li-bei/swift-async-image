import UIKit

extension UIImageView {
    private static var tasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    
    public func setImage(from url: URL?, loader: AsyncImageLoader = .shared, completion: ((Error?) -> Void)? = nil) {
        let id = ObjectIdentifier(self)
        Self.tasks[id]?.cancel()
        Self.tasks[id] = nil
        image = nil
        guard let url else {
            return
        }
        
        if let image = loader.cachedImage(from: url) {
            self.image = image
        } else {
            Self.tasks[id] = Task { [weak self] in
                do {
                    let image = try await loader.image(from: url)
                    if !Task.isCancelled {
                        self?.image = image
                        completion?(nil)
                    }
                } catch {
                    if !Task.isCancelled {
                        completion?(error)
                    }
                }
            }
        }
    }
}
