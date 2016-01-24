//
//  Memes.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/23/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

//class that encapsulates a singleton shared instance of type [MemeObjects] which can be shared/accessed across view controllers and will hold the saved memed images
class Memes {
    static let sharedInstance = Memes()
    var savedMemes = [MemeObject]()
    
    private init() { }
}