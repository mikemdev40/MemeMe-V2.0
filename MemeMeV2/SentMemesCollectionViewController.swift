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
    //the delegate and datasource are set as soon as the tableview outlet is set
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    //connecting to the collection view's flow layout object enables its customization
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //MARK: CONSTANTS
    struct Constants {
        static let CellVerticalSpacing: CGFloat = 2
    }
    
    //MARK: CUSTOM METHODS
    ///this method is the action attached to the "+" button in the navigation bar and causes a segue to occur (prepareForSegue is invoked here, but because the destination view controller doesn't need to be set up when adding a new meme, no setup specific to the "showMemeEditorFromCollection" segue identifier occurs in the prepareForSegue call)
    func addMeme() {
        performSegueWithIdentifier("showMemeEditorFromCollection", sender: nil)
    }
    
    ///this method determines the cell layout (and does do differently depending on whether the device is in portrait or landscape mode) and is called when "viewDidLayoutSubviews" is called (which happens multiple times throughout the view controller's lifecycle, as well as when the device is phycially rotated)
    func layoutCells() {
        var cellWidth: CGFloat
        var numWide: CGFloat
        
        //sets the number of cells to display horizontally in each row based on the device's orientation
        switch UIDevice.currentDevice().orientation {
        case .Portrait:
            numWide = 3
        case .PortraitUpsideDown:
            numWide = 3
        case .LandscapeLeft:
            numWide = 4
        case .LandscapeRight:
            numWide = 4
        default:
            numWide = 4
        }
        //sets the cell width to be dependent upon the number of cells that will be displayed in each row, as determined directly above
        cellWidth = collectionView.frame.width / numWide

        //updates the cell width to account for the desired cell spacing (a predetermined constant, defined in the Constants struct), then updates the itemSize accordingly
        cellWidth -= Constants.CellVerticalSpacing
        flowLayout.itemSize.width = cellWidth
        flowLayout.itemSize.height = cellWidth
        flowLayout.minimumInteritemSpacing = Constants.CellVerticalSpacing
        
        //calculates the actual vertical spacing between cells, accounting for the additional vertical space that was subtracted from the cell width (e.g. if there are 3 cells, there are only 2 vertical spaces, not 3); then by setting the line spacing to be equal to this "actual" value, the vertical and horizontal distances between cells should be exact (or as close to exact as possible)
        let actualCellVerticalSpacing: CGFloat = (collectionView.frame.width - (numWide * cellWidth))/(numWide - 1)
        flowLayout.minimumLineSpacing = actualCellVerticalSpacing
        
        //causes the collection view to invalidate its current layout and relay out the collection view using the new settings in the flow layout (without this call, the cells don't properly resize upon rotation)
        flowLayout.invalidateLayout()
    }
    
    //MARK: DELEGATE METHODS
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        //sets up the prototype cell's display settings
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.cornerRadius = 5
        cell.memeImage.clipsToBounds = true
        cell.memeImage.contentMode = .ScaleAspectFill
        
        //sets the data of each cell using the shared saved memes array; note that the imageview of the cell is being updated to the memed image as retrieved using the "getImage" method on the meme object using the "Memed" ImageType (this method and type are both defined as part of the MemeObject class), as well as the global "getDateFromMeme" function which is defined in the functions.swift file (and also used by the table view)
        let memeCollection = Memes.sharedInstance.savedMemes
        cell.memeImage.image = memeCollection[indexPath.row].getImage(MemeObject.ImageType.Memed)
        cell.memeLabel.text = "Shared " + getDateFromMeme(memeCollection[indexPath.row])

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Memes.sharedInstance.savedMemes.count
    }
    
    //MARK: VIEW CONTROLLER METHODS
    //preparation is necessary when segueing to the meme viewer from the table view after tapping on a specific meme call (but not when seguing to the meme editor when tapping the "+" button), and this preparation involves setting the memeToDisplay property to the specific meme that was selected; since outlets are NOT yet set on the destination view controller, it was not possible to set the imageView.image property directly from prepareForSegue, and instead the memeToDisplay property is set (which, when the meme viewer is about to appear, enables the imageView.image to THEN be set using the meme information passed in memeToDisplay, since outlets are set the time "viewWillAppear" is called)
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
    
    //this method is called several times through the view controller's life cycle, particularly when the device is rotated; ths layOutCells() method is invoked whenever viewDidLayoutSubviews is called (either as a result of being loaded or being rotated) which updates the collection view based on the orientation, as defined in layOutCells().
    override func viewDidLayoutSubviews() {
        layoutCells()
    }
    
    //MARK: VIEW CONTROLLER LIFECYCLE
    override func viewWillAppear(animated: Bool) {
        collectionView.reloadData()
    }
    
    //in viewDidLoad, the navigation bar is set up with the "+" button to segue to the meme editor and the title is set (to prevent the "Sent Memes" title from appering in the tab bar button underneath the tab bar button icon, it was necessary to set the view's title = "" and the navigationItem's title to "Sent Memes")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(SentMemesCollectionViewController.addMeme))
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        //sets title to "" sets both navigation bar title AND tab bar title to ""; subsequently setting navigationItem's title to "Sent Memes" allowed just this title to be shown in the navigation bar (and not under the tab bar icon)
        title = ""
        navigationItem.title = "Sent Memes"
    }
}
