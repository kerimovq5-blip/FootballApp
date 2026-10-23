//
//  ImageLoader.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//

//
//  ImageLoader.swift
//  FootballApp
//

import UIKit

final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Nəticə həmişə main thread-də qaytarılır; şəkil yüklənməsə nil.
    func load(_ urlString: String?, completion: @escaping (UIImage?) -> Void) {
        guard let urlString, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        let key = urlString as NSString
        if let cached = cache.object(forKey: key) {
            completion(cached)
            return
        }
        session.dataTask(with: url) { [weak self] data, _, _ in
            let image = data.flatMap { UIImage(data: $0) }
            if let image {
                self?.cache.setObject(image, forKey: key)
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
