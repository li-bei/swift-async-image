import UIKit

private let logger = makeLogger()

extension UIButton {
    private static var tasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    
    public func setAsyncImage(url: URL?, loader: AsyncImageLoader = .shared) {
        let id = ObjectIdentifier(self)
        Self.tasks[id]?.cancel()
        Self.tasks[id] = nil
        setImage(nil, for: .normal)
        guard let url else {
            return
        }
        
        if let image = loader.cachedImage(from: url) {
            setImage(image, for: .normal)
        } else {
            Self.tasks[id] = Task { [weak self] in
                do {
                    let image = try await loader.image(from: url)
                    if Task.isCancelled == false {
                        self?.setImage(image, for: .normal)
                    }
                } catch {
                    logger.error("\(error)")
                }
                if Task.isCancelled == false {
                    Self.tasks[id] = nil
                }
            }
        }
    }
}
