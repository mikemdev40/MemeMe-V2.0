//
//  Memes.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/23/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

//class that encapsulates a thread-safe singleton instance of type [MemeObjects] which can be shared/accessed across view controllers and will hold the saved memed images (as an alternative approach to using the app delegate to store a single instance of an object)

class Memes {
    static let sharedInstance = Memes()
    var savedMemes = [MemeObject]()
    
    private init() { }
}