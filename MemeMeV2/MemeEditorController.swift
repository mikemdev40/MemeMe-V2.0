//
//  ViewController.swift
//  MemeMeV1
//
//  Created by Michael Miller on 1/16/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit
import MobileCoreServices

//note the adoption of the UpdateFontDelegate protocol below, which is defined in the EditOptionsViewController class and adopted by this MemeEditorController class; delegation is used in this application for the purpose of enabling the user to change the font of the meme from a popover view controller, and have the font change immediately reflected on the main view controller screen

class MemeEditorController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UpdateFontDelegate {
    
    //MARK: OUTLETS
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blackBackground: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    //MARK: CONSTANTS
    struct Constants {
        static let placeholderText = "TAP TO EDIT"
        static let defaultFont = UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
        static let defaultScale = UIViewContentMode.ScaleAspectFit
        static let optionsPopoverSize = CGSize(width: 215, height: 125)
    }
    
    //MARK: PROPERTIES
    var barSpace: UIBarButtonItem!
    var cameraButton: UIBarButtonItem!
    var albumButton: UIBarButtonItem!
    var optionsButton: UIBarButtonItem!
    var activeTextField: UITextField?
    var meme: MemeObject!
    let notificationCenter = NSNotificationCenter.defaultCenter()

    //variable for the font of the textfields, which, when set to a different values, causes the textfields to update through the didset property observer's call of setText (which set the text field attributes)
    var memeFont = Constants.defaultFont {
        didSet { setText() }
    }
    //property that is required by the UpdateFontDelegate protocol; when newFontStyle is set in the popover options screen, the property observer on this variable sets memeFont to the new font
    var newFontStyle = Constants.defaultFont {
        didSet { memeFont = newFontStyle }
    }
    
    //MARK: COMPUTED PROPERTIES
    var memeTextAttributes: [String: AnyObject] {
        return [NSStrokeColorAttributeName: UIColor.blackColor(),
            NSStrokeWidthAttributeName: -2,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: memeFont]
    }
    
    //MARK: METHODS
    func pickImageFromAlbum() {
        getImage(.PhotoLibrary)
    }
    
    func takeImageWithCamera() {
        getImage(.Camera)
    }
    
    func getImage(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    //method that creates a meme image
    func createMeme() -> UIImage {
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    //method that shares the meme using a UIActivityViewContoller, then saves the image to an instance of the MemeObject struct using the completion handler for the activity controller; the save occurs after any activity is selected, however, a save does NOT occur if the user clicks "cancel" (i.e. activity == nil) or there is an error; an appropriate alert is shown to the user after the save occurs (or doesn't)
    func shareAndSaveMeme() {
        guard let topText = topTextField.text, let bottomText = bottomTextField.text else {
            callAlert("Missing Text", message: "Make sure you have text typed!")
            return
        }
        
        if let imageToMeme = imageView.image {
            let memedImage = createMeme()
            let shareVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: [])
            shareVC.completionWithItemsHandler = {[unowned self] (activity, choseAnAction, returnedItems, error) -> Void in
                if error != nil {
                    self.callAlert("Error", message: error!.localizedDescription)
                } else if activity != nil {
                    self.meme = MemeObject(topText: topText, bottomText: bottomText, originalImage: imageToMeme, memedImage: memedImage)
                    self.callAlert("SAVED", message: "Memed image was saved.")
                } else {
                    self.callAlert("Not Saved", message: "Memed image did not save because you cancelled.")
                }
            }
            presentViewController(shareVC, animated: true, completion: nil)
        } else {
            callAlert("No Image", message: "You must have an image selected in order to share!")
        }
    }
    
    //method that presents the options view controller (as a popoever, even on iPhone) for controlling image scale and font selection; delegation is used for the purpose of enabling the user to update the font from the popover and have the font update in real time (without needing to dismiss the popover); an "UpdateFontDelegate" protocol is defined in the editoptionsviewcontroller class, and this class adopts the protocol by declaring a newFontStyle variable (which, when set in the popover by choosing a new font, updates the value of memeFont which then calls the setText() method to update the screen).
    func showOptions() {
        if let eovc = storyboard?.instantiateViewControllerWithIdentifier("optionsViewController") as? EditOptionsViewController {
            eovc.modalPresentationStyle = .Popover
            if let popover = eovc.popoverPresentationController {
                popover.delegate = self
                popover.barButtonItem = optionsButton
                popover.backgroundColor = UIColor.whiteColor()
                eovc.preferredContentSize = Constants.optionsPopoverSize
                eovc.imageView = imageView
                eovc.currentFont = memeFont
                eovc.delegate = self
                
                //creating and presenting the popover in code rather than using segues on the storyboard was used because the "presentViewController" function comes with a completion callback which was needed in order to set the passthroughViews property to nil, thus preventing the user form interacting with the "Albums" button on the toolbar while the popover was up (note that setting this property before presenting the popover did NOT disable the toolbar interactivity, and thus access to this closure was necessary); performing a segue did not provide a callback option
                presentViewController(eovc, animated: true, completion: { [unowned popover] () -> Void in
                    popover.passthroughViews = nil
                })
            }
        }
    }
    
    //method that "resets" the image and the text when the cancel button is tapped in the top right corner
    func cancel() {
        imageView.image = nil
        topTextField.text = Constants.placeholderText
        bottomTextField.text = Constants.placeholderText
        memeFont = Constants.defaultFont
        imageView.contentMode = Constants.defaultScale
        blackBackground.backgroundColor = UIColor.clearColor()
    }
    
    //method that sets up the top and bottom meme text fields (note that the memeTextAttributes is a computed property which uses the value of "memeFont" as the font, which can be set using the options button)
    func setText() {
        topTextField.borderStyle = .None
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        topTextField.adjustsFontSizeToFitWidth = false
        topTextField.minimumFontSize = 20
        
        bottomTextField.borderStyle = .None
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .Center
        bottomTextField.adjustsFontSizeToFitWidth = false
        bottomTextField.minimumFontSize = 20
        
        if topTextField.text == "" {
            topTextField.text = Constants.placeholderText
        }
        if bottomTextField.text == "" {
            bottomTextField.text = Constants.placeholderText
        }
    }
    
    //method for creating an alert with a specific title and message
    func callAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    //the two methods below are called when a keyboardWillShow or keyboardWillHide notification is received; the shiftView method is passed a closure as an argument which defines the operation (either addition or subtraction) that should occur to the view's frame based on if the keyboard is showing or hiding; shorthand closure notation is used for convenience.
    func keyboardWillShow(notification: NSNotification) {
        shiftView(notification) { return $0 - $1 }
    }

    func keyboardWillHide(notification: NSNotification) {
        shiftView(notification) { return $0 + $1 }
    }
    
    //method for shifting the view in response to the keyboard showing or hiding; the method has a closure parameter which takes two CGFloats and either adds or subtracts them; the shift up/down only occurs if the bottom textfield is active (the bottom textfield has a tag set to 2); the two CGFloats being operated on are the y coordinate of the view's frame and an "offset" involving the height of the keyboard and the height of the toolbar (note that the "activefield" property is set to whichever textfield is clicked on, set in the textFieldDidBeginEditing delegate method below)
    func shiftView(notification: NSNotification, operation: (CGFloat, CGFloat) -> CGFloat) {
        if let tag = activeTextField?.tag {
            if tag == 2 {
                if let toolbarHeight = navigationController?.toolbar.frame.size.height {
                    view.frame.origin.y = operation(view.frame.origin.y, (getKeyboardHeight(notification) - toolbarHeight))
                }
            }
        }
    }
    
    //method that extracts the height of the keyboard from the userinfo property of the notification
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    //method that subscribes the viewcontroller to receive keyboard notifications
    func subscribeToKeyboardNotifications() {
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    //method that unsubscribes the viewcontroller from keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: DELEGATE METHODS
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
           image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        blackBackground.backgroundColor = UIColor.blackColor()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //delegate method that is called when a textfield is clicked on; the activefield property is set here, for use when determining if the keyboard should cause the view to shift up or not
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        if textField.text == Constants.placeholderText {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            textField.text = Constants.placeholderText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //delegte method used to override the iphone's automatic adapting of a popover into a modal view controller (this was needed in order to maintain the popover bubble on an iphone)
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //MARK: VIEW CONTROLLER METHODS
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: VIEW CONTROLLER LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meme Editor"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareAndSaveMeme")
    
        barSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        cameraButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "takeImageWithCamera")
        albumButton = UIBarButtonItem(title: "Album", style: .Plain, target: self, action: "pickImageFromAlbum")
        optionsButton = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: "showOptions")

        toolbarItems = [barSpace, albumButton, barSpace, cameraButton, barSpace, optionsButton, barSpace]
        navigationController?.toolbarHidden = false
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        albumButton.enabled = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            messageLabel.text = "Choose an image from your album or take a photo to begin!"
        } else {
            messageLabel.text = "Choose an image from your album to begin!"
        }
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.tag = 1
        bottomTextField.tag = 2
        
        setText()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
}

