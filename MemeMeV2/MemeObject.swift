//
//  MemeObject.swift
//  MemeMeV1
//
//  Created by Michael Miller on 1/16/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation
import UIKit

struct MemeObject {
    
    enum ImageType {
        case Original
        case Memed
    }
    
    var topText: String
    var bottomText: String
    var originalImageURL: NSURL
    var memedImageURL: NSURL
    var date: NSDate
    
    func getImage(type: ImageType) -> UIImage? {
        if type == .Original {
            return retrieveImage(originalImageURL)
        } else if type == .Memed {
            return retrieveImage(memedImageURL)
        }
        return nil
    }
    
    private func retrieveImage(url: NSURL) -> UIImage? {
        if let imageData = NSData(contentsOfURL: url) {
            if let image = UIImage(data: imageData) {
                return image
            }
        }
        return nil
    }
}