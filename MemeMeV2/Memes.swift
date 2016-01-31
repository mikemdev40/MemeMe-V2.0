//
//  Memes.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/23/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

//this class below encapsulates a thread-safe singleton instance of type [MemeObjects] which can be shared/accessed across view controllers and will hold the saved memed images (as an alternative approach to using the app delegate to store a single instance of an object); the singleton is also what is updated and saved to disk when a new meme is added to or deleted from the array, and is set to the saved meme data on the file disk when the app is first launched

class Memes {
    static let sharedInstance = Memes()
    var savedMemes = [MemeObject]()
    
    private init() { }
}

//my primary references for learning about how to best implement a singleton were http://krakendev.io/blog/the-right-way-to-write-a-singleton and https://thatthinginswift.com/singletons/