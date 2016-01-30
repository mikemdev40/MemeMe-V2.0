//
//  MemeDetailViewController.swift
//  MemeMeV2
//
//  Created by Michael Miller on 1/24/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var memeToDisplay: MemeObject?

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMemeEditorFromViewer" {
            var destinationViewController = segue.destinationViewController
            if let navigationViewController = destinationViewController as? UINavigationController {
                destinationViewController = navigationViewController.viewControllers[0]
                if let memeViewController = destinationViewController as? MemeEditorController {
                    if let memeToSend = memeToDisplay {
                        memeViewController.memeToEdit = memeToSend
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        tabBarController?.tabBar.hidden = true
        imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = memeToDisplay?.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
