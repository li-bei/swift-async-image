import Foundation
import os

public final class FileDownloader: NSObject, Sendable {
    public static let shared = FileDownloader()
    
    private override init() {}
    
    private let tasks = OSAllocatedUnfairLock<[URL: Task<URL, Error>]>(initialState: [:])
    
    public func fileURL(for url: URL) -> URL {
        return URL.cachesDirectory
            .appending(path: "\(FileDownloader.self)", directoryHint: .isDirectory)
            .appending(path: url.host()!, directoryHint: .isDirectory)
            .appending(path: url.path())
    }
    
    public func isFileDownloaded(from url: URL) -> Bool {
        let fileURL = fileURL(for: url)
        return FileManager.default.fileExists(atPath: fileURL.path())
    }
    
    @discardableResult
    public func downloadFile(from url: URL) async throws -> URL {
        let fileURL = fileURL(for: url)
        if isFileDownloaded(from: url) {
            return fileURL
        }
        
        if let task = tasks.withLock({ $0[url] }) {
            return try await task.value
        }
        
        let task = Task {
            let (tempURL, _) = try await URLSession.shared.download(from: url, delegate: self)
            let fileManager = FileManager.default
            try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try fileManager.moveItem(at: tempURL, to: fileURL)
            return fileURL
        }
        
        tasks.withLock { $0[url] = task }
        
        do {
            let fileURL = try await task.value
            tasks.withLock { $0[url] = nil }
            return fileURL
        } catch {
            tasks.withLock { $0[url] = nil }
            throw error
        }
    }
}

// MARK: - URLSessionTaskDelegate

extension FileDownloader: URLSessionTaskDelegate {
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        return request
    }
}
