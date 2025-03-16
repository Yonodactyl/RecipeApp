//
//  ImageCacheServiceTests.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import XCTest
import UIKit
@testable import Recipe_App

final class ImageCacheServiceTests: XCTestCase {
    
    class TestMockUIImage: UIImage, @unchecked Sendable { }
    
    var imageCacheService: ImageCacheService!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSessionFactory.createMockSession()
        imageCacheService = ImageCacheService(session: mockSession)
    }
    
    override func tearDown() {
        MockURLSessionFactory.clearMocks()
        imageCacheService.clearCache()
        imageCacheService = nil
        mockSession = nil
        super.tearDown()
    }
    
    private func createTestImage(color: UIColor, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func testLoadImageFromNetwork() async throws {
        // Arrange
        let testImage = createTestImage(color: .red)
        let imageData = testImage.jpegData(compressionQuality: 1.0)!
        let imageURL = "https://example.com/test.jpg"
        
        MockURLSessionFactory.setupSuccessResponse(for: imageURL, with: imageData)
        
        // Act
        let loadedImage = try await imageCacheService.loadImage(from: imageURL)
        
        // Assert
        XCTAssertNotNil(loadedImage)
    }
    
    func testLoadImageInvalidURL() async {
        // Arrange
        let invalidURL = ""
        
        // Act & Assert
        do {
            _ = try await imageCacheService.loadImage(from: invalidURL)
            XCTFail("Expected error but load succeeded")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoadImageDownloadFailed() async {
        // Arrange
        let imageURL = "https://example.com/nonexistent.jpg"
        MockURLSessionFactory.setupInvalidResponse(for: imageURL, statusCode: 404)
        
        // Act & Assert
        do {
            _ = try await imageCacheService.loadImage(from: imageURL)
            XCTFail("Expected error but load succeeded")
        } catch let error as ImageLoadingError {
            XCTAssertEqual(error, ImageLoadingError.downloadFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoadImageInvalidData() async {
        // Arrange
        let imageURL = "https://example.com/invalid.jpg"
        MockURLSessionFactory.setupSuccessResponse(for: imageURL, with: Data([0, 1, 2, 3]))
        
        // Act & Assert
        do {
            _ = try await imageCacheService.loadImage(from: imageURL)
            XCTFail("Expected error but load succeeded")
        } catch let error as ImageLoadingError {
            XCTAssertEqual(error, ImageLoadingError.invalidData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoadImageMemoryCaching() async throws {
        // Arrange
        let testImage = createTestImage(color: .blue)
        let imageData = testImage.jpegData(compressionQuality: 1.0)!
        let imageURL = "https://example.com/cached-test.jpg"
        
        MockURLSessionFactory.setupSuccessResponse(for: imageURL, with: imageData)
        
        // Act
        _ = try await imageCacheService.loadImage(from: imageURL)
        let cachedImage = try await imageCacheService.loadImage(from: imageURL)
        
        // Arrange
        let newTestImage = createTestImage(color: .green)
        let newImageData = newTestImage.jpegData(compressionQuality: 1.0)!
        
        MockURLSessionFactory.clearMocks()
        MockURLSessionFactory.setupSuccessResponse(for: imageURL, with: newImageData)
        
        // Assert
        let cachedImageData = cachedImage.jpegData(compressionQuality: 1.0)!
        XCTAssertNotEqual(cachedImageData, newImageData, "Image should be from cache, not newly downloaded")
    }
    
    func testClearCache() async throws {
        // Arrange
        let testImage = createTestImage(color: .yellow)
        let imageData = testImage.jpegData(compressionQuality: 1.0)!
        let imageURL = "https://example.com/to-be-cleared.jpg"
        
        MockURLSessionFactory.setupSuccessResponse(for: imageURL, with: imageData)
        
        // Act
        _ = try await imageCacheService.loadImage(from: imageURL)
        let reloadedImage = try await imageCacheService.loadImage(from: imageURL)
        let reloadedImageData = reloadedImage.jpegData(compressionQuality: 1.0)!
        
        imageCacheService.clearCache()
        
        // Arrange
        let newTestImage = createTestImage(color: .purple)
        let newImageData = newTestImage.jpegData(compressionQuality: 1.0)!
        
        MockURLSessionFactory.clearMocks()
        MockURLSessionFactory.setupSuccessResponse(for: imageURL, with: newImageData)
        
        // Assert
        XCTAssertNotNil(reloadedImage, "Image should be successfully reloaded after cache cleared")
    }
    
    func testLoadImageFromDiskCache() async throws {
        // Arrange
        let testImage = createTestImage(color: .orange)
        let imageData = testImage.jpegData(compressionQuality: 1.0)!
        let imageURL = "https://example.com/disk-cache-test.jpg"
        
        MockURLSessionFactory.setupSuccessResponse(for: imageURL, with: imageData)
        
        let initialImage = try await imageCacheService.loadImage(from: imageURL)
        
        imageCacheService.testMemoryCache.removeAllObjects()
        
        MockURLSessionFactory.clearMocks()
        
        let newImage = createTestImage(color: .brown)
        let newImageData = newImage.jpegData(compressionQuality: 1.0)!
        MockURLSessionFactory.setupSuccessResponse(for: imageURL, with: newImageData)
        
        let diskCachedImage = try await imageCacheService.loadImage(from: imageURL)
        
        // Assert
        XCTAssertNotNil(diskCachedImage, "Image should be loaded from disk cache")
        
        let initialImageData = initialImage.jpegData(compressionQuality: 1.0)!
        let diskCachedImageData = diskCachedImage.jpegData(compressionQuality: 1.0)!
        
        XCTAssertEqual(initialImageData.count, diskCachedImageData.count, "Image from disk cache should match original image size")
    }
    
    func testDirectCacheFileAccess() throws {
        let testURL = "https://example.com/test-path.jpg"
        let filePath = imageCacheService.testCacheFilePath(for: testURL)
        
        XCTAssertTrue(filePath.absoluteString.contains("ImageCache"), "Cache file path should be in the ImageCache directory")
        XCTAssertTrue(filePath.absoluteString.contains(testURL.hashValue.description), "Cache file path should use the URL hash")
    }
    
    func testSaveAndLoadImageToDiskCache() throws {
        let testImage = createTestImage(color: .cyan)
        let testURL = "https://example.com/direct-disk-cache-test.jpg"
        
        try imageCacheService.testSaveImageToDiskCache(testImage, with: testURL)
        
        let loadedImage = try imageCacheService.testLoadImageFromDiskCache(with: testURL)
        
        XCTAssertNotNil(loadedImage, "Image should be loaded from disk cache")
    }
    
    func testDiskCacheReadFailure() {
        let uncachedURL = "https://example.com/uncached-image.jpg"
        
        do {
            _ = try imageCacheService.testLoadImageFromDiskCache(with: uncachedURL)
            XCTFail("Expected error but disk cache read succeeded")
        } catch let error as ImageLoadingError {
            XCTAssertEqual(error, ImageLoadingError.cacheReadFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testInvalidImageDataInDiskCache() throws {
        let invalidURL = "https://example.com/invalid-cached-data.jpg"
        let invalidData = Data([0, 1, 2, 3])
        
        let cacheFile = imageCacheService.testCacheFilePath(for: invalidURL)
        try invalidData.write(to: cacheFile)
        
        do {
            _ = try imageCacheService.testLoadImageFromDiskCache(with: invalidURL)
            XCTFail("Expected error but load succeeded with invalid data")
        } catch let error as ImageLoadingError {
            XCTAssertEqual(error, ImageLoadingError.invalidData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCacheWriteFailure() {
        
        let mockImage = TestMockUIImage()
        let testURL = "https://example.com/write-failure-test.jpg"
        
        do {
            try imageCacheService.testSaveImageToDiskCache(mockImage, with: testURL)
            XCTFail("Expected error but save succeeded")
        } catch let error as ImageLoadingError {
            XCTAssertEqual(error, ImageLoadingError.invalidData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCacheDirectoryCreation() {
        let fileManager = FileManager.default
        let directoryExists = fileManager.fileExists(atPath: imageCacheService.testCacheDirectory.path)
        
        XCTAssertTrue(directoryExists, "Cache directory should be created during initialization")
    }
}
