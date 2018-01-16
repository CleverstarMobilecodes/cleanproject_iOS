//
//  UIImageMaskExtension.swift
//  earnit
//
//  Created by Prakash Chettri on 27/07/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit


extension UIImageView {
    
    func maskWith(color: UIColor) {
        guard let tempImage = image?.withRenderingMode(.alwaysTemplate) else { return }
        image = tempImage
        tintColor = color
    }
    
}

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String?) {
        
        self.image = EarnItImage.setLoadingImage();
        //self.contentMode = UIViewContentMode.scaleAspectFill
        //self.contentMode = UIViewContentMode.center
        
        if let url = URL(string: urlString!){
       
    
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as! NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as! NSString)

                    self.image = image
                }
                else{
                    self.image = nil
                }
               // self.contentMode = UIViewContentMode.scaleAspectFill
            }
            
           }).resume()
            
        }
    }
    
    
    func loadImageUsingCacheForTask(withUrl urlString : String?) {
        
        self.image = EarnItImage.setLoadingImageForTask();
        //self.contentMode = UIViewContentMode.scaleAspectFill
        //self.contentMode = UIViewContentMode.center
        
     
        if let url = URL(string: urlString!){
            
            // check cached image
            if let cachedImage = imageCache.object(forKey: urlString as! NSString) as? UIImage {
                self.image = cachedImage
                return
            }
            
            // if not, download image from url
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    if let image = UIImage(data: data!) {
                        imageCache.setObject(image, forKey: urlString as! NSString)
                        
                        self.image = image
                    }
                    else{
                        self.image = nil
                    }
                    // self.contentMode = UIViewContentMode.scaleAspectFill
                }
                
            }).resume()
            
        }
    }
}
