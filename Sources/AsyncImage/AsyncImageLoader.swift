import UIKit

@MainActor
public final class AsyncImageLoader {
    public static let shared = AsyncImageLoader()
    
    private let imageProcessor: (@Sendable (UIImage) -> UIImage)?
    
    public init(imageProcessor: (@Sendable (UIImage) -> UIImage)? = nil) {
        self.imageProcessor = imageProcessor
    }
    
    private let cache = NSCache<NSURL, UIImage>()
    
    public func cachedImage(from url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    private var tasks: [URL: Task<UIImage, Error>] = [:]
    
    public func image(from url: URL) async throws -> UIImage {
        if let task = tasks[url] {
            return try await task.value
        }
        
        let task = Task.detached(priority: .high) { [imageProcessor] in
            let fileURL = try await FileDownloader.shared.downloadFile(from: url)
            if var image = UIImage(contentsOfFile: fileURL.path()) {
                if let imageProcessor {
                    image = imageProcessor(image)
                }
                return image.preparingForDisplay() ?? image
            } else {
                throw AsyncImageError()
            }
        }
        
        tasks[url] = task
        
        do {
            let image = try await task.value
            cache.setObject(image, forKey: url as NSURL)
            tasks[url] = nil
            return image
        } catch {
            tasks[url] = nil
            throw error
        }
    }
}
