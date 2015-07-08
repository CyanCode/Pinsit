//
//  PostDetailsView.swift
//  Pinsit
//
//  Created by Walker Christie on 2/21/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class PostDetailsView: SlideInView, UITextViewDelegate {
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet var downloadSwitch: UISwitch!
    @IBOutlet var privateSwitch: UISwitch!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var postButton: UIButton!
    
    var responder: UIViewController!
    //private var popup: KLCPopup!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    ///Used for object initialization, called manually when initialized
    func prepareView() {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.bounds.height)
        
        downloadSwitch.enabled = Upgrade().isUpgraded()
        downloadSwitch.onTintColor = UIColor(string: "#FF2851")
        privateSwitch.onTintColor = UIColor(string: "#FF2851")
        fillerText()
        
        //Buttons and TextView
        postButton.layer.cornerRadius = 3
        postButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 3
        cancelButton.layer.masksToBounds = true
        descriptionView.layer.cornerRadius = 3
        descriptionView.layer.masksToBounds = true
        
        //Full View
        self.layer.cornerRadius = 3
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.descriptionView.delegate = self
    }
    
    ///Present PostDetailsView in DetailsViewController, ready to post
    ///
    ///- parameter viewController: DetailsViewController instance
    func presentViewInController(viewController: UIViewController, popupPoint: CGPoint) {
        self.responder = viewController
        self.prepareView()
        viewController.view.addSubview(self)
        
        self.slideIn { () -> Void in }
        //        popup = KLCPopup(contentView: self)
        //        popup.showAtCenter(responder.view.center, inView: responder.view)
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        //popup.dismiss(true)
        self.dismissSlide()
    }
    
    var descriptionSet: Bool!
    private func fillerText() {
        descriptionView.textColor = UIColor.grayColor()
        descriptionView.text = "Try adding a description!"
        descriptionSet = false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if descriptionSet == false {
            descriptionView.text = ""
            descriptionView.textColor = UIColor.blackColor()
            descriptionSet = true
        }
    }
    
    @IBAction func postPressed(sender: AnyObject) {
        postVideo()
    }
    
    func postVideo() {
        if descriptionSet == false {
            descriptionView.text = ""
        }
        
        //self.popup.dismiss(true)
        self.dismissSlide()
        let postingProgress = JGProgressHUD(frame: self.frame)
        postingProgress.textLabel.text = "Posting"
        postingProgress.showInView(self.responder.view)
        
        PAnnotation().postAnnotation(self, completion: { (error) -> Void in
            postingProgress.dismissAnimated(true)
            
            if error != nil {
                self.postingError()
                self.dismissSlide()
                //self.popup.dismiss(true)
            } else {
                print("Video post successful")
                //self.popup.dismiss(true)
                self.dismissSlide()
                //segue
            }
        })
        
    }
    
    private func postingError() {
        let alert = UIAlertController(title: "Oops", message: "Your video didn't post successfully, would you like to try again?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            self.postVideo()
        }))
        alert.addAction(UIAlertAction(title: "Nope", style: .Cancel, handler: nil))
        responder.presentViewController(alert, animated: true, completion: nil)
    }
}

extension UIView {
    class func detailViewFromNib() -> PostDetailsView {
        return UINib(nibName: "PostDetailsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PostDetailsView
    }
}