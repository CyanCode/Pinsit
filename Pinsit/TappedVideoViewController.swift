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

class TappedVideoViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet var videoView: ExpandedVideoView!
    @IBOutlet var commentsView: AnimateUpwardsView!
    @IBOutlet var limitLabel: UILabel!
    @IBOutlet var usernameButton: UIButton!
    @IBOutlet var textField: UITextField!
    
    var videoObject: PFSentData!
    private var dataHandler: PinVideoData!
    private var manager: PinVideoManager!
    
    var commentController: CommentsViewController {
        get {
            return self.childViewControllers[0] as! CommentsViewController
        }
    }
    
    //MARK: View loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        AppDelegate.loginCheck(self)
        
        self.startPlaying()
        self.dataHandler = PinVideoData(viewController: self)
        self.usernameButton.setTitle(videoObject.username, forState: .Normal)
        
        videoView.adjustGravityOnResize(manager.layer)
        commentController.videoId = videoObject.objectId!
        commentController.loadObjects()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.hidden = true
        
        manager.recoverVideo()
    }
    
    var isHiddenFirst = false
    override func viewDidLayoutSubviews() {
        if !isHiddenFirst {
            commentsView.hidden = true
            isHiddenFirst = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        manager.endVideo()
    }
    
    ///MARK: Actions
    
    var showingComments = false
    @IBAction func showCommentsButton(sender: UIButton) {
        if commentsView.hidden { //Reveal UIView but send to bottom
            commentsView.isHidden(true)
            commentsView.hidden = false
        }
        
        if showingComments {
            commentsView.isHiddenAnimated(true)
            showingComments = false
        } else {
            commentsView.isHiddenAnimated(false)
            showingComments = true
        }
    }
    
    @IBAction func moreButton(sender: UIButton) {
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

    @IBAction func usernameTapped(gesture: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("accountSegue", sender: nil)
    }
    
    @IBAction func postCommentPressed(sender: UIButton) {
        if textField.text!.characters.count > 0 {
            let comment = PFComments()
            comment.username = PFUser.currentUser()!.username!
            comment.videoId = videoObject.objectId!
            comment.comment = textField.text
            
            comment.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error != nil {
                    ErrorReport(viewController: self).presentWithType(.Network)
                } else {
                    self.commentController.loadObjects()
                }
            })
        } else {
            ErrorReport(viewController: self).presentError("Missing Something?", message: "You need to add some text before you post a comment!", type: .Error)
        }
    }
    
    @IBAction func returnButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "accountSegue" {
            let vc = segue.destinationViewController as! AccountViewController
            vc.user = videoObject.username
        }
    }
    
    //MARK: Status bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

class AnimateUpwardsView: UIView {
    var hasTabBar: Bool = true
    let tabBarSize = 49
    
    func isHidden(hidden: Bool) {
        if hidden {
            self.frame = CGRectMake(0, superview!.frame.height, frame.width, frame.height)
        } else {
            let yPos = (superview!.frame.height - frame.height) - CGFloat(hasTabBar ? tabBarSize : 0)
            self.frame = CGRectMake(0, yPos, frame.width, frame.height)
        }
    }
    
    func isHiddenAnimated(hidden: Bool) {
        if hidden {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.frame = CGRectMake(0, self.superview!.frame.height, self.frame.width, self.frame.height)
            })
        } else {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                let yPos = (self.superview!.frame.height - self.frame.height) - CGFloat(self.hasTabBar ? self.tabBarSize : 0)
                self.frame = CGRectMake(0, yPos, self.frame.width, self.frame.height)
            })
        }
    }
}

@IBDesignable class TextLimitTextField: UITextField {
    var limitLabel: UILabel!
    @IBInspectable var correctLengthColor: UIColor = UIColor.grayColor()
    @IBInspectable var incorrectLengthColor: UIColor = UIColor.redColor()
    @IBInspectable var characterLimit: Int = 200
}