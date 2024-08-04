//
//  MyImageView.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import UIKit

class MyImageView: UIImageView {
    
    static var cache = NSCache<AnyObject, UIImage>()
    var url: URL?
    
    func encodeURL(urlString: String) -> String? {
        urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    func loadImages(from stringURL: String) {
        guard let encodedURL = encodeURL(urlString: stringURL) else { return }
        self.url = URL(string: encodedURL)
        let activityIndicator = self.activityIndicator
        
        if let cachedImage = MyImageView.cache.object(forKey: url as AnyObject) {
            self.image = cachedImage
        } else {
            DispatchQueue.main.async {
                activityIndicator.startAnimating()
            }
            guard let url = url else {return}
            URLSession.shared.dataTask(with: url) { (data, respone, error) in
                if let error = error {
                    print ("Error: \(error)")
                } else if let data = data {
                    if url == self.url {
                        DispatchQueue.main.async {
                            if let imageObtained = UIImage(data: data) {
                            self.image = imageObtained
                            MyImageView.cache.setObject(imageObtained, forKey: url as AnyObject)
                            }
                        }
                    } else {
                        print("error")
                    }
                }
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
            }.resume()
        }
    }
}
