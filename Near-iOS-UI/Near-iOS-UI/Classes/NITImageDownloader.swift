//
//  NITImageDownloader.swift
//  NearUIBinding
//
//  Created by Federico Boschini on 26/11/2018.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit

public class NITImageDownloader: NSObject {
    
    @objc public static let sharedInstance = NITImageDownloader()
    
    var imageCache: [String: UIImage] = [:]
    
    func downloadImageWithUrl(url: URL,
                              completionBlock: @escaping (_ succeeded: Bool, _ image: UIImage?, _ url: URL) -> Void) {
        if let cachedImage = self.imageCache[url.absoluteString] {
            completionBlock(true, cachedImage, url)
        } else {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else {
                        completionBlock(false, nil, url)
                        return
                }
                
                DispatchQueue.main.async { () -> Void in
                    completionBlock(true, image, url)
                    self.imageCache[url.absoluteString] = image
                }
            }.resume()
        }
    }
}
