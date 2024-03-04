import UIKit

extension UIImageView {
    private static var tasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    
    private static let logger = makeLogger()
    
    public func setAsyncImage(url: URL?, loader: AsyncImageLoader = .shared) {
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
                    if Task.isCancelled == false {
                        self?.image = image
                    }
                } catch {
                    Self.logger.error("\(error)")
                }
                if Task.isCancelled == false {
                    Self.tasks[id] = nil
                }
            }
        }
    }
}
