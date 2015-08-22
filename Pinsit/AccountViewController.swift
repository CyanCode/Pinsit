//
//  AccountViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/8/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
import ParseUI
import JGProgressHUD
import Bolts
import QuartzCore

@IBDesignable class AccountViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var profileActivity: UIActivityIndicatorView!
    
    @IBOutlet var followingLabel: AccountInformationLabel!
    @IBOutlet var followerLabel: AccountInformationLabel!
    @IBOutlet var karmaLabel: AccountInformationLabel!
    
    var user: String!
    var locationManager: CLLocationManager!
    var detailManager: AccountDetails!
    var temporaryImg: UIImage?
    var location: CLLocationCoordinate2D?
    var followTableView: FollowerQueryTableViewController {
        get {
            return self.childViewControllers.last as! FollowerQueryTableViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.loginCheck(self)
        
        user = user == nil ? PFUser.currentUser()!.username! : user
        self.detailManager = AccountDetails(viewController: self, user: user)
        
        profileActivity.hidden = true
        self.followingLabel.selected = true
        
        loadInformation()
        prepareInterface()
    }
    
    override func viewDidAppear(animated: Bool) {
        AppDelegate.loginCheck(self)
        
        followTableView.username = user
        followTableView.loadObjects()
    }
    
    func prepareInterface() {
        if user == PFUser.currentUser()!.username! {
            let imageTap = UITapGestureRecognizer(target: self, action: Selector("profileTapped:"))
            profileImage.userInteractionEnabled = true
            profileImage.addGestureRecognizer(imageTap)
        }
        
        detailManager.loadProfileImage { (img) -> Void in
            self.profileImage.image = img
        }
    }
    
    ///MARK: Information labels
    func loadInformation() {
        let progress = JGProgressHUD(style: .Dark)
        progress.textLabel.text = "Loading"
        progress.showInView(self.view, animated: true)
        
        self.usernameLabel.text = user
        self.view.bringSubviewToFront(progress)
        self.setInfoHidden(true)
        
        detailManager.setAccountDetails { () -> Void in
            self.setInfoHidden(false)
            progress.dismiss()
        }
    }
    
    func setInfoHidden(hidden: Bool) {
        followingLabel.hidden = hidden
        followerLabel.hidden = hidden
        karmaLabel.hidden = hidden
    }
    
    @IBAction func followingPressed(sender: UIButton) {
        if followTableView.queryType != .Following {
            followingLabel.selected = true
            followerLabel.selected = false
            
            followTableView.queryType = .Following
            followTableView.loadObjects()
        }
    }
    
    @IBAction func followerPressed(sender: UIButton) {
        if followTableView.queryType != .Followers {
            followingLabel.selected = false
            followerLabel.selected = true
            
            followTableView.queryType = .Followers
            followTableView.loadObjects()
        }
    }
    
    ///MARK: Profile picture
    func profileTapped(gesture: UITapGestureRecognizer) {
        let controller = UIAlertController(title: "Change Profile Picture", message: "", preferredStyle: .ActionSheet)
        
        controller.addAction(UIAlertAction(title: "Choose Photo", style: .Default, handler: { (action) -> Void in
            self.profileWithType(.PhotoLibrary)
        }))
        controller.addAction(UIAlertAction(title: "Take Photo", style: .Default, handler: { (action) -> Void in
            self.profileWithType(.Camera)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func profileWithType(type: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = type
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        uploadNewProfile(image)
        picker.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func uploadNewProfile(img: UIImage!) {
        let file = PFFile(data: UIImagePNGRepresentation(img.resize(CGSizeMake(100, 100)))!)
        let user = PFUser.currentUser()!
        
        user["profileImage"] = file
        self.changeProfileImage(true)
        
        user.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                let message = UIAlertController(title: "Upload Error", message: "Your profile picture failed to upload to the server, make sure you are connected to the internet!", preferredStyle: .Alert)
                message.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                
                self.presentViewController(message, animated: true, completion: nil)
            } else {
                print("Profile Image upload success")
                self.temporaryImg = img
                self.detailManager.setImage(img)
            }
            
            self.changeProfileImage(false)
        }
    }
    
    func changeProfileImage(editing: Bool) {
        if editing == true {
            temporaryImg = profileImage.image!
            profileImage.image = UIImage()
            profileActivity.hidden = false
            profileActivity.startAnimating()
        } else {
            profileImage.image = temporaryImg == nil ? profileImage.image! : temporaryImg!
            profileActivity.hidden = true
            profileActivity.stopAnimating()
        }
    }
    
    ///Status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

///Designable circular profile picture
@IBDesignable class ExtendedImageView: UIImageView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
}

class AccountInformationLabel: UILabel {
    var oldFont: UIFont?
    var alreadySelected: Bool = false
    var selected: Bool = false {
        didSet {
            if selected && !alreadySelected {
                oldFont = self.font
                alreadySelected = true
                
                let font = UIFont(name: "\(self.font.fontName)-Bold", size: self.font.pointSize)
                self.font = font
            } else {
                alreadySelected = false
                
                if oldFont != nil {
                    self.font = oldFont
                }
            }
        }
    }
}

class AccountQueryCell: PFTableViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var karmaLabel: UILabel!
    @IBOutlet var profileImage: FollowerImageView!
}