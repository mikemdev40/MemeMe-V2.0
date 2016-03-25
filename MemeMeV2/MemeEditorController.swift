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
    var shareAndSaveButton: UIBarButtonItem!
    var activeTextField: UITextField?
    var meme: MemeObject!
    var memeToEdit: MemeObject?
    let notificationCenter = NSNotificationCenter.defaultCenter()

    //variable for the font of the textfields, which, when set to a different value, causes the textfields to update through the didset property observer's call of setText (which set the text field attributes)
    var memeFont = Constants.defaultFont {
        didSet {
            setText(Constants.placeholderText, bottomText: Constants.placeholderText)
        }
    }
    
    //property that is required by the UpdateFontDelegate protocol; when newFontStyle is set in the popover options screen, the property observer on this variable sets memeFont to the new font
    var newFontStyle = Constants.defaultFont {
        didSet {
            memeFont = newFontStyle
        }
    }
    
    //MARK: COMPUTED PROPERTIES
    var memeTextAttributes: [String: AnyObject] {
        return [NSStrokeColorAttributeName: UIColor.blackColor(),
            NSStrokeWidthAttributeName: -2,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: memeFont]
    }
    
    //MARK: CUSTOM METHODS
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
    
    ///this method creates a meme image
    func createMeme() -> UIImage {
        UIGraphicsBeginImageContext(view.bounds.size)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    ///this method shares the meme using a UIActivityViewContoller then saves the image to an instance of the MemeObject class using the completion handler for the activity controller; the save occurs after any activity is selected, however, a save does NOT occur if the user clicks "cancel" (i.e. activity == nil) or there is an error; an appropriate alert is shown to the user after the save occurs (or doesn't); if an activity is selected, the meme gets saved, and a completion handler is passed to the callAlert method which dismisses the meme editor that is being modally presented
    func shareAndSaveMeme() {
        guard let topText = topTextField.text, let bottomText = bottomTextField.text else {
            callAlert("Missing Text", message: "Make sure you have text typed!", handler: nil)
            return
        }
        
        if let imageToMeme = imageView.image {
            let memedImage = createMeme()
            let shareVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: [])
            shareVC.completionWithItemsHandler = {[unowned self] (activity, choseAnAction, returnedItems, error) -> Void in
                if error != nil {
                    self.callAlert("Error", message: error!.localizedDescription, handler: nil)
                } else if activity != nil {
                    self.saveMeme(topText, bottomText: bottomText, originalImage: imageToMeme, memedImage: memedImage, date: NSDate())
                    self.callAlert("SAVED", message: "Memed image was saved.") {
                        [unowned self] (action) -> Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                    }
                } else {
                    self.callAlert("Not Saved", message: "Memed image did not save because you cancelled.", handler: nil)
                }
            }
            shareVC.modalPresentationStyle = .Popover
            shareVC.popoverPresentationController?.barButtonItem = shareAndSaveButton
            presentViewController(shareVC, animated: true, completion: nil)
        } else {
            callAlert("No Image", message: "You must have an image selected in order to share!", handler: nil)
        }
    }
    
    /// this method presents the options view controller (as a popoever, even on iPhone) for controlling image scale and font selection; delegation is used for the purpose of enabling the user to update the font from the popover and have the font update in real time (without needing to dismiss the popover); an "UpdateFontDelegate" protocol is defined in the editoptionsviewcontroller class, and this class adopts the protocol by declaring a newFontStyle variable (which, when set in the popover by choosing a new font, updates the value of memeFont which then calls the setText() method to update the screen).
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
    
    ///this method writes the both the original and memed images to disk as JPEGs, saves the memed imaged (and original image and text) to an instance of the archivable type MemeObject, then update the singleton [MemeObject] instance (which is shared across view controllers) by appending the new meme object and saves the shared [MemeObject] to disk using NSKeyedArchiver
    func saveMeme(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage, date: NSDate) {
        let manager = NSFileManager.defaultManager()
        if let documentsPath = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
            var randomFileName = NSUUID().UUIDString
            
            let originalImagePath = randomFileName
            let originalImagePathURL = documentsPath.URLByAppendingPathComponent(originalImagePath)
            if let originalImageData = UIImageJPEGRepresentation(originalImage, 1.0) {
                originalImageData.writeToURL(originalImagePathURL, atomically: true)
            }
            
            randomFileName = NSUUID().UUIDString
            
            let memedImagePath = randomFileName
            let memedImagePathURL = documentsPath.URLByAppendingPathComponent(memedImagePath)
            if let memedImageData = UIImageJPEGRepresentation(memedImage, 1.0) {
                memedImageData.writeToURL(memedImagePathURL, atomically: true)
            }

            meme = MemeObject(topText: topText, bottomText: bottomText, originalImagePath: originalImagePath, memedImagePath: memedImagePath, date: date)
            Memes.sharedInstance.savedMemes.insert(meme, atIndex: 0)

            NSKeyedArchiver.archiveRootObject(Memes.sharedInstance.savedMemes, toFile: getMemeFilePath())
        }
    }
    //my primary references for storing files to the local disk was lecture 16 of the Stanford iTunes Course (https://itunes.apple.com/us/course/developing-ios-8-apps-swift/id961180099) and https://www.hackingwithswift.com/read/10/4/importing-photos-with-uiimagepickercontroller
    
    
    ///this method causes the meme editor view to disappear (this was changed from MemeMe V1.0, in which the "cancel" button just reset everything rather than dismissing a view controller)
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///this method sets up the top and bottom meme text fields (note that the memeTextAttributes is a computed property which uses the value of "memeFont" as the font, which can be set using the edit options popover via the "Options" button)
    func setText(topText: String, bottomText: String) {
        
        setupTextField(topTextField)
        setupTextField(bottomTextField)
        
        if topTextField.text == "" {
            topTextField.text = topText
        }
        if bottomTextField.text == "" {
            bottomTextField.text = bottomText
        }
    }
    
    func setupTextField(textField: UITextField) {
        textField.borderStyle = .None
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.adjustsFontSizeToFitWidth = false
        textField.minimumFontSize = 20
    }
    
    ///this method creates an alert with a specific title, message, and completion handler (as a note, the only time a completion handler is provided is when the user selects an activity from the share meme menu; in this casae the "OK" button then leads to a dismissal of the meme editor)
    func callAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    //this method is called when a keyboardWillShow notification is received; the shiftView method is passed a closure as an argument which defines that subtraction should occur to the view's frame based on the keyboard showing; shorthand closure notation is used for convenience.
    func keyboardWillShow(notification: NSNotification) {
        shiftView(notification) { return $0 - $1 }
    }
   
    //this method is called when a keyboardWillHide notification is received; the shiftView method is passed a closure as an argument which defines that addition should occur to the view's frame based on the keyboard hiding; shorthand closure notation is used for convenience.
    func keyboardWillHide(notification: NSNotification) {
        shiftView(notification) { return $0 + $1 }
    }
    
    ///this method causes the view to shift in response to the keyboard showing or hiding; the method has a closure parameter which takes two CGFloats and either adds or subtracts them; the shift up/down only occurs if the bottom textfield is active (the bottom textfield has a tag set to 2); the two CGFloats being operated on are the y coordinate of the view's frame and an "offset" involving the height of the keyboard and the height of the toolbar (note that the "activefield" property is set to whichever textfield is clicked on, set in the textFieldDidBeginEditing delegate method below)
    func shiftView(notification: NSNotification, operation: (CGFloat, CGFloat) -> CGFloat) {
        if let tag = activeTextField?.tag {
            if tag == 2 {
                if let toolbarHeight = navigationController?.toolbar.frame.size.height {
                    view.frame.origin.y = operation(view.frame.origin.y, (getKeyboardHeight(notification) - toolbarHeight))
                }
            }
        }
    }
    
    ///this method extracts the height of the keyboard from the userinfo property of the notification
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    ///this method subscribes the viewcontroller to receive keyboard notifications
    func subscribeToKeyboardNotifications() {
        notificationCenter.addObserver(self, selector: #selector(MemeEditorController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(MemeEditorController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    ///this method unsubscribes the viewcontroller from keyboard notifications
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
    //in viewdidload, the navigation bar and toolbar buttons are added, the background text is adjusted based on sourcetype availability, delegates are set, and the original image is loaded if this view is being segued to from the meme viewer (otherwise, there is no initial image showing, other than the default background)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Editor"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(MemeEditorController.cancel))
        shareAndSaveButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(MemeEditorController.shareAndSaveMeme))
        navigationItem.leftBarButtonItem = shareAndSaveButton
            
        barSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        cameraButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(MemeEditorController.takeImageWithCamera))
        albumButton = UIBarButtonItem(title: "Album", style: .Plain, target: self, action: #selector(MemeEditorController.pickImageFromAlbum))
        optionsButton = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: #selector(MemeEditorController.showOptions))

        toolbarItems = [barSpace, albumButton, barSpace, cameraButton, barSpace, optionsButton, barSpace]
        
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
        
        //loads the original image used in the meme only if this view is being segued to from the meme viewer (in which case, a meme is loaded and when the segue occurs, the prepareforsegue from the meme viewer to this meme editor sets the memeToEdit variable to be equal to the original image; if this segue does not occur, then memeToEdit is nil and "else" runs).
        if let memeToEdit = memeToEdit {
            imageView.image = memeToEdit.getImage(MemeObject.ImageType.Original)
            blackBackground.backgroundColor = UIColor.blackColor()
            setText(memeToEdit.topText, bottomText: memeToEdit.bottomText)
        } else {
            setText(Constants.placeholderText, bottomText: Constants.placeholderText)
        }
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

