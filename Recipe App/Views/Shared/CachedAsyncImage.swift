//
//  CachedAsyncImage.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//
import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let imageCacheService: ImageCacheServiceProtocol
    private let urlString: String?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var loadingError: Error?
    
    init(
        urlString: String?,
        imageCacheService: ImageCacheServiceProtocol = ImageCacheService(),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.urlString = urlString
        self.imageCacheService = imageCacheService
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
            } else if let urlString = urlString, UIImage(named: urlString) != nil {
                content(Image(urlString))
            } else if isLoading {
                placeholder()
            } else if loadingError != nil {
                placeholder()
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let urlString = urlString, !urlString.isEmpty else {
            return
        }
        
        if UIImage(named: urlString) != nil {
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let loadedImage = try await imageCacheService.loadImage(from: urlString)
                await MainActor.run {
                    self.uiImage = loadedImage
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.loadingError = error
                    self.isLoading = false
                }
            }
        }
    }
}

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(
        urlString: String?,
        imageCacheService: ImageCacheServiceProtocol = ImageCacheService(),
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            urlString: urlString,
            imageCacheService: imageCacheService,
            content: content,
            placeholder: { ProgressView() }
        )
    }
}
