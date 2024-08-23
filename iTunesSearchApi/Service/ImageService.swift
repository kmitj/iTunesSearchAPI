//
//  ImageService.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import Foundation
import UIKit

class ImageService {
    
    static let instance = ImageService()
    
    private let session: URLSession
    var imageCache = NSCache<NSString, UIImage>()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = url.absoluteString as NSString
        if let cachedImage = self.imageCache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        let task = self.session.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            self.imageCache.setObject(image, forKey: cacheKey)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
}
