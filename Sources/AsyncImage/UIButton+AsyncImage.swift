import UIKit

private let logger = makeLogger()

extension UIButton {
    private static var tasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    
    public func setImage(from url: URL?, loader: AsyncImageLoader = .shared) {
        let id = ObjectIdentifier(self)
        Self.tasks[id]?.cancel()
        setImage(nil, for: .normal)
        if let url {
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
                }
            }
        }
    }
}
