//
//  SentMemesCollectionViewController.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/24/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //MARK: CONSTANTS
    struct Constants {
        static let CellHorizontalSpacing: CGFloat = 2
        static let CellVerticalSpacing: CGFloat = 2
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //CUSTOM METHODS
    ///method to add a meme
    func addMeme() {
        performSegueWithIdentifier("showMemeEditorFromCollection", sender: nil)
    }
    
    ///method that lays out the cells, and does do differently depending on whether the device is in portrait or landscape mode
    func layoutCells() {
        var cellWidth: CGFloat
        if UIDevice.currentDevice().orientation.isPortrait {
            cellWidth = collectionView.frame.width / 3
        } else {
            cellWidth = collectionView.frame.width / 4
        }
        cellWidth -= Constants.CellVerticalSpacing
        flowLayout.itemSize.width = cellWidth
        flowLayout.itemSize.height = cellWidth
        flowLayout.minimumInteritemSpacing = Constants.CellVerticalSpacing
        flowLayout.minimumLineSpacing = Constants.CellHorizontalSpacing
    }
    
    //DELEGATE METHODS
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        let memeCollection = Memes.sharedInstance.savedMemes
        
        cell.memeImage.clipsToBounds = true
        cell.memeImage.image = memeCollection[indexPath.row].memedImage
        cell.memeLabel.text = memeCollection[indexPath.row].topText
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blackColor().CGColor
    
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Memes.sharedInstance.savedMemes.count

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //VIEW CONTROLLER METHODS
    override func viewDidLayoutSubviews() {
        layoutCells()
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMeme")
        
        collectionView.backgroundColor = UIColor.whiteColor()
        title = "Sent Memes"
        
    }
    
}
