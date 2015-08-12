//
//  TappedVideoViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/4/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD
import TSMessages

class TappedVideoViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var navItem: UINavigationItem!
    @IBOutlet var videoView: ExpandedVideoView!
    
    var videoObject: PFSentData!
    private var dataHandler: PinVideoData!
    private var manager: PinVideoManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        AppDelegate.loginCheck(self)
        
        self.startPlaying()
        self.dataHandler = PinVideoData(viewController: self)
        videoView.adjustGravityOnResize(manager.layer)
        //self.tableView.readyTableView(videoObject)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navItem.title = videoObject.username
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let view = navigationController!.navigationBar.subviews[1] as UIView
        view.userInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "usernameTapped:"))
        
        manager.recoverVideo()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        manager.endVideo()
    }
    
    @IBAction func moreButton(sender: AnyObject) {
        let title = videoObject.desc == "" ? "Post Options" : videoObject.desc
        let controller = UIAlertController(title: title, message: videoObject.desc, preferredStyle: .ActionSheet)
        
        if videoObject.username != PFUser.currentUser()!.username! {
            if videoObject.downloading == true {
                controller.addAction(UIAlertAction(title: "Download", style: .Default, handler: { (action) -> Void in
                    self.dataHandler.downloadVideo()
                }))
            }
            controller.addAction(UIAlertAction(title: "Report", style: .Default, handler: { (action) -> Void in
                self.dataHandler.reportUser(self.videoObject.username, videoId: self.videoObject.objectId!)
            }))
        } else {
            controller.addAction(UIAlertAction(title: "Download", style: .Default, handler: { (action) -> Void in
                self.dataHandler.downloadVideo()
            }))
            controller.addAction(UIAlertAction(title: "Delete Post", style: .Default, handler: { (action) -> Void in
                self.videoObject.deletePinPost({ (error) -> Void in
                    if error == nil {
                        PFUser.currentUser()!.incrementKarmaLevel(-3)
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        ErrorReport(viewController: self).presentWithType(.Network)
                    }
                })
            }))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func followButton(sender: AnyObject) {
        self.dataHandler.addFollower(videoObject.username, button: sender as! UIButton)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    
    //var profileDetails: ProfileInfo?
    func usernameTapped(gesture: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("accountSegue", sender: nil)
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "accountSegue" {
            let vc = segue.destinationViewController as! AccountViewController
            vc.user = videoObject.username
            vc.location = videoObject.location.coordinate
        }
    }
}