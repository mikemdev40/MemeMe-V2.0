//
//  Functions.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/27/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

//MARK: GLOBAL FUNCTIONS
//the function below 
func getDateFromMeme(meme: MemeObject) -> String {
    let date = meme.date
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.ShortStyle
    let dateAsString = formatter.stringFromDate(date)
    
    return dateAsString
}

func getMemeFilePath() -> String {
    let manager = NSFileManager.defaultManager()
    if let documentsPath = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
        let memeFilePath = documentsPath.URLByAppendingPathComponent("MemeObjectArray")
        if let memeFilePathString = memeFilePath.path {
            return memeFilePathString
        }
    }
    return ""
}