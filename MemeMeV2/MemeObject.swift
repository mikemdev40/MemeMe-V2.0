//
//  MemeObject.swift
//  MemeMeV1
//
//  Created by Michael Miller on 1/16/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation
import UIKit

//this model was updated from MemeMe V1.0 from a struct to a class so that it was possible to adopt the NSCoding protocol for the purpose of persistence of the memes data in between launches
class MemeObject: NSObject, NSCoding {
    
    //this enum type was established to simplify the call to the "getImage" method below, which returns either the memed image or the original image from the file disk, based on which version of the image is needed; both the table view and collection view use this type when calling the getImage method on each meme object when setting up their respective cells, and the meme editor uses the type when it is segued to from the meme viewer
    enum ImageType {
        case Original
        case Memed
    }
    
    var topText: String
    var bottomText: String
    var originalImagePath: String
    var memedImagePath: String
    var date: NSDate
    
    ///this class method is used to locate and return the original and memed images from the file disk using the documents directory and the randomly generated path strings for the image file paths when the meme is created in the meme editor; the ImageType is used to simplify the call to this method so that it is clear which version of the image is being requested; the table view and collection view controllers call this method with the "Memed" type when setting up their cells, since they want to display the saved memes, whereas the "Original" type is used solely when the "Create New From" button is tapped in the meme viewer, which segues to the meme editor and loads the original version of the image into the imageview.
    func getImage(type: ImageType) -> UIImage? {
        if type == .Original {
            return retrieveImage(originalImagePath)
        } else if type == .Memed {
            return retrieveImage(memedImagePath)
        }
        return nil
    }
    
    ///this private method is called by the getImage above and returns the actual image from the file disk to the getImage function (it exists as a separate method from getImage to reduce redundant code)
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
    
    //MARK: REQUIRED PROTOCOL METHODS
    //the methods below are required by the NSCoding protocol and are used for setting up the MemeObject class for enabling a [MemeObject] array to persist in between app launches
    
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
    //my primary references for learning about using NSKeyedArchiving to persist custom classes were http://mhorga.org/2015/08/25/ios-persistence-with-nscoder-and-nskeyedarchiver.html and https://www.hackingwithswift.com/read/12/3/fixing-project-10-nscoding
}