//
//  Functions.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/27/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

func getDateFromMeme(meme: MemeObject) -> String {
    
    let date = meme.date
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.ShortStyle
    let convertedDate = formatter.stringFromDate(date)
    
    return convertedDate
}