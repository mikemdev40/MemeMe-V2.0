//
//  SentMemesTableViewController.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/24/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    func addMeme() {
        performSegueWithIdentifier("showMemeEditorFromTable", sender: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell") as! MemeTableViewCell
        // accidentally had cell.clipstobounds and cell.contentmode set, rather than the imageview
        cell.tableCellImageView.layer.borderWidth = 1
        cell.tableCellImageView.layer.borderColor = UIColor.blackColor().CGColor
        cell.tableCellImageView.layer.cornerRadius = 5
        cell.tableCellImageView.clipsToBounds = true
        cell.tableCellImageView.contentMode = .ScaleAspectFill
        
        let memeCollection = Memes.sharedInstance.savedMemes
        
        cell.tableCellTopLabel.text = memeCollection[indexPath.row].topText
        cell.tableCellBottomLabel.text = memeCollection[indexPath.row].bottomText
        cell.tableCellDateLabel.text = "Shared on " + getDateFromMeme(memeCollection[indexPath.row])
        cell.tableCellImageView.image = memeCollection[indexPath.row].memedImage
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return Memes.sharedInstance.savedMemes.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TableToMemeViewer" {
            if let memeViewController = segue.destinationViewController as? MemeDetailViewController {
                if let cell = sender as? MemeTableViewCell {
                    if let indexPath = tableView.indexPathForCell(cell) {
                        memeViewController.memeToDisplay = Memes.sharedInstance.savedMemes[indexPath.row]
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMeme")
        
        title = "Sent Memes"
    }

}
