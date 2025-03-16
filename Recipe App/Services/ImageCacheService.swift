//
//  ImageCacheService.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation
import UIKit

protocol ImageCacheServiceProtocol {
    func loadImage(from urlString: String) async throws -> UIImage
    func clearCache()
}

class ImageCacheService: ImageCacheServiceProtocol {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let cacheDirectory: URL
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
        
        let fileManager = FileManager.default
        let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cacheURL.appendingPathComponent("ImageCache", isDirectory: true)
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            } catch {
                print("Error creating cache directory: \(error)")
            }
        }
        
        memoryCache.name = "RecipeImageCache"
        memoryCache.countLimit = 100
    }
    
    func loadImage(from urlString: String) async throws -> UIImage {
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        if let diskCachedImage = try? loadImageFromDiskCache(with: urlString) {
            memoryCache.setObject(diskCachedImage, forKey: cacheKey)
            return diskCachedImage
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageLoadingError.downloadFailed
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageLoadingError.invalidData
        }
        
        memoryCache.setObject(image, forKey: cacheKey)
        try saveImageToDiskCache(image, with: urlString)
        
        return image
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        
        let fileManager = FileManager.default
        do {
            let cacheContents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for fileURL in cacheContents {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing disk cache: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func cacheFilePath(for urlString: String) -> URL {
        let fileName = urlString.hashValue.description
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func loadImageFromDiskCache(with urlString: String) throws -> UIImage {
        let filePath = cacheFilePath(for: urlString)
        
        guard let data = try? Data(contentsOf: filePath) else {
            throw ImageLoadingError.cacheReadFailed
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageLoadingError.invalidData
        }
        
        return image
    }
    
    private func saveImageToDiskCache(_ image: UIImage, with urlString: String) throws {
        let filePath = cacheFilePath(for: urlString)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageLoadingError.invalidData
        }
        
        do {
            try data.write(to: filePath)
        } catch {
            throw ImageLoadingError.cacheWriteFailed
        }
    }
}

extension ImageCacheService {
    var testMemoryCache: NSCache<NSString, UIImage> {
        return memoryCache
    }
    
    var testCacheDirectory: URL {
        return cacheDirectory
    }
    
    func testLoadImageFromDiskCache(with urlString: String) throws -> UIImage {
        return try loadImageFromDiskCache(with: urlString)
    }
    
    func testSaveImageToDiskCache(_ image: UIImage, with urlString: String) throws {
        try saveImageToDiskCache(image, with: urlString)
    }
    
    func testCacheFilePath(for urlString: String) -> URL {
        return cacheFilePath(for: urlString)
    }
}
