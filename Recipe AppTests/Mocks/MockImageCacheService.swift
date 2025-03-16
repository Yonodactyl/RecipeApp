//
//  MockImageCacheService.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation
import UIKit
@testable import Recipe_App

class MockImageCacheService: ImageCacheServiceProtocol {
    var shouldSucceed = true
    var loadImageCalled = false
    var clearCacheCalled = false
    var lastRequestedURL: String?
    var mockImage = UIImage()
    
    func loadImage(from urlString: String) async throws -> UIImage {
        loadImageCalled = true
        lastRequestedURL = urlString
        
        if !shouldSucceed {
            throw ImageLoadingError.downloadFailed
        }
        
        return mockImage
    }
    
    func clearCache() {
        clearCacheCalled = true
    }
}
