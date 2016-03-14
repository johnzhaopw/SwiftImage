//
//  UIImage+ImageCache.swift
//  SwiftImage
//
//  Created by John Zhao on 3/6/16.
// Copyright © 2016 Phunware Inc. All rights reserved.
//

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import ObjectiveC

extension UIImageView {

    func getImageCache(urlString:String?) -> UIImage? {
        if let urlString = urlString {
            return MyImageCache.sharedCache.objectForKey(urlString) as? UIImage
        }
        else {
            return nil
        }
    }
    
    public func imageFromUrl(urlString: String?) {
        guard urlString != nil
            else {
                self.image = nil;
                return
        }
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: urlString!)
        let request = NSURLRequest(URL: url!)
        if let image = self.getImageCache(urlString) {
            self.image = image
        }
        else {
            usedURLString = urlString
            let task = session.dataTaskWithRequest(request) { (data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    guard data != nil && error == nil
                        else {
                            return
                    }
                    if (self.usedURLString == urlString) {
                        self.image = UIImage(data: data!)
                        guard self.image != nil
                            else {
                                return
                        }
                        MyImageCache.sharedCache.setObject(
                            self.image!,
                            forKey: urlString!,
                            cost: data!.length)
                        self.setNeedsDisplay()
                    }
                })
            }
            task.resume()
        }
    }
}

extension UIImageView {
    private struct AssociateKeys {
        static var DescriptionName = "SwiftImageHelper_ImageAssociate"
    }
    var usedURLString: String? {
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.DescriptionName) as? String
        }
        set {
            if let newValue = newValue {
            objc_setAssociatedObject(self, &AssociateKeys.DescriptionName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

class MyImageCache {
    static let sharedCache: NSCache  = {
        let cache = NSCache()
        cache.name = "SwiftImageHelperImageCache"
        cache.countLimit = 100
        cache.totalCostLimit = 100*1024*1024
        return cache
    }()
}
