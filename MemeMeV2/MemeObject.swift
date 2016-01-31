//
//  MemeObject.swift
//  MemeMeV1
//
//  Created by Michael Miller on 1/16/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation
import UIKit

class MemeObject: NSObject, NSCoding {
    
    enum ImageType {
        case Original
        case Memed
    }
    
    var topText: String
    var bottomText: String
    var originalImagePath: String
    var memedImagePath: String
    var date: NSDate
    
    func getImage(type: ImageType) -> UIImage? {
        if type == .Original {
            return retrieveImage(originalImagePath)
        } else if type == .Memed {
            return retrieveImage(memedImagePath)
        }
        return nil
    }
    
    private func retrieveImage(path: String) -> UIImage? {
        let manager = NSFileManager.defaultManager()
        if let documentsPath = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
            let memeFilePath = documentsPath.URLByAppendingPathComponent(path)
            if let imageData = NSData(contentsOfURL: memeFilePath) {
                if let image = UIImage(data: imageData) {
                    return image
                }
            }
        }
        return nil
    }
    
    init(topText: String, bottomText: String, originalImagePath: String, memedImagePath: String, date: NSDate) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImagePath = originalImagePath
        self.memedImagePath = memedImagePath
        self.date = date
    }
    
    //REQUIRED NSCODING PROTOCOL METHODS for persisting [MemeObjects] in between app launches
    required init?(coder aDecoder: NSCoder) {
        topText = aDecoder.decodeObjectForKey("topText") as! String
        bottomText = aDecoder.decodeObjectForKey("bottomText") as! String
        originalImagePath = aDecoder.decodeObjectForKey("originalImagePath") as! String
        memedImagePath = aDecoder.decodeObjectForKey("memedImagePath") as! String
        date = aDecoder.decodeObjectForKey("date") as! NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(topText, forKey: "topText")
        aCoder.encodeObject(bottomText, forKey: "bottomText")
        aCoder.encodeObject(originalImagePath, forKey: "originalImagePath")
        aCoder.encodeObject(memedImagePath, forKey: "memedImagePath")
        aCoder.encodeObject(date, forKey: "date")
    }
}