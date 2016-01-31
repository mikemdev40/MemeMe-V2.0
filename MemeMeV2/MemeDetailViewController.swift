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
    
    //an optional property which is set by the view controller that is segueing to this view controller via the prepareForSegue method; this property was necessary to serve as an intermediate step between the segue occurring (when the outlets were not set) and when this view controller is about to appear (when outlets have been set) because it wasn't possible to set imageView.image directly from prepareForSegue (because imageView is nil at that time); this property ALSO exists for the purpose of passing along the currently viewed meme to the meme editor when the "Create New From" button is presed
    var memeToDisplay: MemeObject?

    //this prepareForSegue first gets a hold of the navigation controller in which the meme editor is the root controller, and THEN connects to the meme editor view controller (which is the first view controller listed in the navigation controller's viewControllers array property); once connected, the current meme is transferred to the meme editor which, when the meme editor appears, loads the ORIGINAL version of the image and the top and bottom texts
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
    //my primary reference for the proper way to access view contollers within navigation controllers was lecture 7 of the Stanford iTunes Course (https://itunes.apple.com/us/course/developing-ios-8-apps-swift/id961180099)
    
    
    //hides the tab bar when the view is about to apper and sets the imageView.image to the memed image property of the meme object (as stored on the file disk and retrieved through the getImage method)
    override func viewWillAppear(animated: Bool) {
        tabBarController?.tabBar.hidden = true
        imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = memeToDisplay?.getImage(MemeObject.ImageType.Memed)
    }
    
    //when the view is about to disapper, the tab bar is unhidden
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false
    }
}
