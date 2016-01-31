//
//  Functions.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/27/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

//MARK: GLOBAL FUNCTIONS
///this function extracts the date from the meme for displaying as part of the table view and collection view; both view controllers call this function when setting up their respective cells in order to provide the "Shared" and "Shared on" date information for each meme (it was saved as a global function since two view controllers use it, and it would be redundant to include the exact same code in both view controller classes)
func getDateFromMeme(meme: MemeObject) -> String {
    let date = meme.date
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.ShortStyle
    let dateAsString = formatter.stringFromDate(date)
    
    return dateAsString
}
//my primary reference for learning how to work with dates was http://www.appcoda.com/nsdate


///this function provides the path name to the saved memes location on the file disk; this function is called by both the table view controller upon loading (since it loads first when the app is launched), by the meme editor when saving an updated memes array to disk, and by both the table view and collection view controllers when deleting a meme (and thus needing to update the memes array saved on the disk).
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