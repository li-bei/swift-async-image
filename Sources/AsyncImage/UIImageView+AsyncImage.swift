import UIKit

private let logger = makeLogger()

extension UIImageView {
    private static var tasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    
    public func setAsyncImage(url: URL?, loader: AsyncImageLoader = .shared) {
        let id = ObjectIdentifier(self)
        Self.tasks[id]?.cancel()
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
                    logger.error("\(error)")
                }
            }
        }
    }
}
