//
//  MPCacheAsyncImageView.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 09/04/24.
//

import SwiftUI

struct MPCacheAsyncImageView<Content>: View where Content: View {
    private var url: URL
    private var scale: CGFloat
    private var transaction: Transaction
    private var content: (AsyncImagePhase) -> Content
    
    init(url: URL, scale: CGFloat = 1.0, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        if let cached = ImageCache[url] {
            content(.success(cached))
        } else {
            AsyncImage(url: url, scale: scale, transaction: transaction) { phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    
    func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success(let image) = phase {
            ImageCache[url] = image
        }
        return content(phase)
    }
}

//#Preview {
//    MPCacheAsyncImage()
//}

// Caching Mechanism for Image for better performance
fileprivate class ImageCache {
    static private var cache: [URL: Image] = [:]
    
    static subscript(url: URL) -> Image? {
        get {
            ImageCache.cache[url]
        } set {
            ImageCache.cache[url] = newValue
        }
    }
}
