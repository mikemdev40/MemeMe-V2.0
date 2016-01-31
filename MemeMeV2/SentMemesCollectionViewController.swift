//
//  SentMemesCollectionViewController.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/24/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    //MARK; OUTLETS
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //MARK: CONSTANTS
    struct Constants {
        static let CellVerticalSpacing: CGFloat = 2
    }
    
    //MARK: CUSTOM METHODS
    ///method to add a meme
    func addMeme() {
        performSegueWithIdentifier("showMemeEditorFromCollection", sender: nil)
    }
    
    ///method that lays out the cells, and does do differently depending on whether the device is in portrait or landscape mode
    func layoutCells() {
        var cellWidth: CGFloat
        var numWide: CGFloat
        if UIDevice.currentDevice().orientation.isPortrait {
            numWide = 3
            cellWidth = collectionView.frame.width / numWide
        } else {
            numWide = 4
            cellWidth = collectionView.frame.width / numWide
        }
        cellWidth -= Constants.CellVerticalSpacing
        flowLayout.itemSize.width = cellWidth
        flowLayout.itemSize.height = cellWidth
        flowLayout.minimumInteritemSpacing = Constants.CellVerticalSpacing
        
        let actualCellVerticalSpacing: CGFloat = (collectionView.frame.width - (numWide * cellWidth))/(numWide - 1)  //calculates the actual vertical distance
        flowLayout.minimumLineSpacing = actualCellVerticalSpacing
    }
    
    //MARK: DELEGATE METHODS
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.cornerRadius = 5
        cell.memeImage.clipsToBounds = true
        cell.memeImage.contentMode = .ScaleAspectFill
        
        let memeCollection = Memes.sharedInstance.savedMemes
        cell.memeImage.image = memeCollection[indexPath.row].getImage(MemeObject.ImageType.Memed)
        cell.memeLabel.text = "Shared " + getDateFromMeme(memeCollection[indexPath.row])

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Memes.sharedInstance.savedMemes.count
    }
    
    //MARK: VIEW CONTROLLER METHODS
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CollectionToMemeViewer" {
            if let memeViewController = segue.destinationViewController as? MemeDetailViewController {
                if let cell = sender as? MemeCollectionViewCell {
                    if let indexPath = collectionView.indexPathForCell(cell) {
                        memeViewController.memeToDisplay = Memes.sharedInstance.savedMemes[indexPath.row]
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        layoutCells()
    }
    
    //MARK: VIEW CONTROLLER LIFECYCLE
    override func viewWillAppear(animated: Bool) {
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMeme")
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        title = ""  //sets both navigation bar title AND tab bar title
        navigationItem.title = "Sent Memes"
        
    }
    
}
