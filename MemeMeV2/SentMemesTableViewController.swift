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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell") as! MemeTableViewCell
        
        let memeCollection = Memes.sharedInstance.savedMemes
        
        cell.textLabel?.text = memeCollection[indexPath.row].topText
        cell.detailTextLabel?.text = memeCollection[indexPath.row].bottomText
        cell.imageView?.image = memeCollection[indexPath.row].memedImage
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return Memes.sharedInstance.savedMemes.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
