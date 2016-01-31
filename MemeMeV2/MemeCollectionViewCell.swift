//
//  MemeCollectionViewCell.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/24/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

//subclass of UICollectionViewCell which allows for a customized appearance of the collection view cell
class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var memeLabel: UILabel!
}
