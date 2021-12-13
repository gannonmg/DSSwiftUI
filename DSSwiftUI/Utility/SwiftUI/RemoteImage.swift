//
//  RemoteImage.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/5/21.
//

import SwiftUI

class UIImageDownloader: NSObject {
    
    private let url: URL?
    private let placeholder: UIImage?
    private let fallback: UIImage?

    private var currentTask: URLSessionDataTask?

    init(from url: URL?, placeholder: UIImage? = nil, fallback: UIImage? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.fallback = fallback
    }

    deinit {
        currentTask?.cancel()
    }

    func fetch(update: @escaping (UIImage?)->()) {
        currentTask?.cancel()
        if let url = url {
            if let cachedImage = ImageCache.shared.imageFor(url) {
                update(cachedImage)
                return
            } else {
                update(placeholder)
            }
        }
        else {
            update(fallback ?? placeholder)
        }
        if let url = url {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    ImageCache.shared.set(image, for: url)
                    DispatchQueue.main.async {
                        update(image)
                    }
                }
            }
            self.currentTask = task
            task.resume()
        }
    }
}

struct RemoteImageView: View {
    
    let placeholder: UIImage
    let contentMode: ContentMode
    @State var downloader: UIImageDownloader
    @State var image: UIImage?

    init(url: URL?, placeholder: UIImage, contentMode: ContentMode = .fit) {
        self.placeholder = placeholder
        self._downloader = State(initialValue: UIImageDownloader(from: url, placeholder: placeholder))
        self.contentMode = contentMode
    }

    var body: some View {
        Image(uiImage: self.image ?? self.placeholder)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .onAppear() {
                self.downloader.fetch {
                    self.image = $0!
                }
            }
    }
}

//MARK: - Image Cache
private class ImageCache: NSCache<NSString, UIImage> {
    
    static let shared = ImageCache()
    
    func set(_ image: UIImage, for url: URL) {
        self.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    func imageFor(_ url: URL?) -> UIImage? {
        guard let url = url else {
            return nil
        }
        return self.object(forKey: url.absoluteString as NSString)
    }

}
