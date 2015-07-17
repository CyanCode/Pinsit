//
//  TappedVideoViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/4/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit

class TappedVideoViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var navItem: UINavigationItem!
    @IBOutlet var videoView: ExpandedVideoView!
    //@IBOutlet var profileImage: UIImageView!
    
    var videoObject: PFObject!
    var expandView: ExpandedVideoView!
    private var dataHandler: PinVideoData!
    private var manager: PinVideoManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        AppDelegate.loginCheck(self)
        
        self.startPlaying()
        self.dataHandler = PinVideoData(viewController: self)
        //self.tableView.readyTableView(videoObject)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoView.adjustGravityOnResize(manager.layer)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navItem.title = videoObject["username"] as? String

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let gesture = UITapGestureRecognizer(target: self, action: "usernameTapped:")
        let view = navigationController!.navigationBar.subviews[1] as UIView
        view.userInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if manager.player != nil { manager.player.pause() }
    }
    
    @IBAction func moreButton(sender: AnyObject) {
        let description = videoObject["description"] as? String != nil ? videoObject["description"] as! String : ""
        let controller = UIAlertController(title: "", message: description, preferredStyle: .ActionSheet)
        
        if dataHandler.isAlreadyLiked(videoObject.objectId!) == false {
            controller.addAction(UIAlertAction(title: "Like", style: .Default, handler: { (action) -> Void in
                self.dataHandler.addLike(self.videoObject.objectId!, button: sender as! UIButton)
            }))
        }
        if videoObject["downloading"] as! NSNumber.BooleanLiteralType == true {
            controller.addAction(UIAlertAction(title: "Download", style: .Default, handler: { (action) -> Void in
                self.dataHandler.downloadVideo()
            }))
        }
        controller.addAction(UIAlertAction(title: "Report", style: .Default, handler: { (action) -> Void in
            self.dataHandler.reportUser(self.videoObject["username"] as! String, videoId: self.videoObject.objectId!)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func followButton(sender: AnyObject) {
        self.dataHandler.addFollower(videoObject["username"] as! String, button: sender as! UIButton)
    }
    
    //var profileDetails: ProfileInfo?
    func usernameTapped(gesture: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("accountSegue", sender: nil)
        
//        if profileDetails == nil {
//            profileDetails = ProfileInfo.loadViewFromNib()
//        }
//        
//        let desc = videoObject["description"] as! String
//        
//        profileDetails?.loadDescriptionWithUsername(PFUser.currentUser()!.username!, description: desc)
//        profileDetails?.loadProfileWithUsername(videoObject["username"] as! String)
//        
//        let popup = KLCPopup(contentView: profileDetails!)
//        popup.showAtCenter(self.view.center, inView: self.view)
    }
    
    private func startPlaying() {
        let progress = JGProgressHUD(style: .Dark)
        progress.textLabel.text = "Loading"
        progress.showInView(self.view)
        
        manager = PinVideoManager(videoView: self.videoView)
        
        VideoManager(object: videoObject).pullVideoData { (data) -> Void in
            if data != nil {
                self.manager.startPlayingWithVideoData(data!, completion: { () -> Void in
                    self.manager.monitorTaps()
                    progress.dismiss()
                })
            } else {
                print("Could not retrieve video data!")
            }
        }
    }
    
    private func getVideoData(object: PFObject, completion: (data: NSData?) -> Void) {
        if VideoCache().pinExistsInCache(object["objectId"] as! String) == true {
            let pin = VideoCache().getPinWithId(videoObject!["objectId"] as! String)
            let file = pin["videoData"] as? PFFile
            
            completion(data: file?.getData())
        } else {
            let id = object["objectId"] as! String
            
            VideoCache().cacheDataFromServer(id, file: object["video"] as! PFFile, completion: { (data) -> Void in
                completion(data: data)
            })
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "accountSegue" {
            let vc = segue.destinationViewController as! AccountViewController
            vc.user = videoObject["username"] as! String
        }
    }
}