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

class AccountViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var map: MKMapView!
    @IBOutlet var karmaLabel: UILabel!
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var postAmountLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    var locationManager: CLLocationManager!
    var detailManager: AccountDetails!
    
    override func viewDidLoad() {
        self.detailManager = AccountDetails(viewController: self)
        
        super.viewDidLoad()
        AppDelegate.loginCheck(self)

        map.userInteractionEnabled = false
        loadInformation()
        toggleHiddenLabels(true)
        readyButtons()
        startLocating()
        prepareInterface()
    }
    
    override func viewDidAppear(animated: Bool) {
        AppDelegate.loginCheck(self)
    }
    
    override func viewDidLayoutSubviews() {
        //        let cover = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        //        cover.frame = map.frame
        //        map.addSubview(cover)
    }
    
    func toggleHiddenLabels(hidden: Bool) {
        for label in [followingLabel, karmaLabel, postAmountLabel] {
            label.hidden = hidden
        }
    }
    
    func readyButtons() {
        for label in [followingLabel, karmaLabel, postAmountLabel] {
            label.backgroundColor = UIColor(red: 255/255, green: 41/255, blue: 81/255, alpha: 1)
            label.layer.cornerRadius = 3
            label.textColor = UIColor.whiteColor()
            label.layer.masksToBounds = true
            self.view.sendSubviewToBack(label)
        }
    }
    
    func prepareInterface() {
        profileImage.image = detailManager.loadImage()
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 3
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor(string: "#FF2951").CGColor
        profileImage.alpha = 1.0
        
        var imageTap = UITapGestureRecognizer(target: self, action: Selector("profileTapped:"))
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
    }
    
    func loadInformation() {
        self.usernameLabel.text = PFUser.currentUser()!.username
        let progress = JGProgressHUD(style: .Dark)
        progress.textLabel.text = "Loading"
        progress.showInView(self.view, animated: true)
        self.view.bringSubviewToFront(progress)
        
        detailManager.setAccountDetails { () -> Void in
            progress.dismiss()
            self.toggleHiddenLabels(false)
        }
    }
    
    func startLocating() {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.House, timeout: 5) { (location, accuracy, status) -> Void in
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            self.map.setRegion(region, animated: true)
        }
    }
    
    func profileTapped(gesture: UITapGestureRecognizer) {
        let controller = UIAlertController(title: "Change Profile Picture", message: "", preferredStyle: .ActionSheet)
        
        controller.addAction(UIAlertAction(title: "Choose Photo", style: .Default, handler: { (action) -> Void in
            self.profileFromCameraRoll()
        }))
        controller.addAction(UIAlertAction(title: "Take Photo", style: .Default, handler: { (action) -> Void in
            self.profileFromTakenImage()
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func profileFromCameraRoll() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func profileFromTakenImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        detailManager.setImage(image)
        profileImage.image = image
        uploadNewProfile(image)
        
        picker.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func uploadNewProfile(img: UIImage!) {
        let file = PFFile(data: UIImagePNGRepresentation(img.resize(CGSizeMake(100, 100))))
        let user = PFUser.currentUser()!
        user["profileImage"] = file
        
        user.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                let message = UIAlertController(title: "Upload Error", message: "Your profile picture failed to upload to the server, make sure you are connected to the internet!", preferredStyle: .Alert)
                message.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                
                self.presentViewController(message, animated: true, completion: nil)
            } else {
                println("Profile Image upload success")
            }
        }
    }
}
