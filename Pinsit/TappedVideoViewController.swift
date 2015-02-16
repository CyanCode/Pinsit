//
//  TappedVideoViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/4/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit

class TappedVideoViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var videoView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var likesTableView: UITableView!

    var videoObject: PFObject!
    private var dataHandler: PinVideoData!
    
    override func viewDidLoad() {
        self.startPlaying()
        self.dataHandler = PinVideoData(viewController: self)
    }
    
    @IBAction func downloadButton(sender: AnyObject) {
        self.dataHandler.downloadVideo()
    }
    
    @IBAction func likeVideoButton(sender: AnyObject) {
        self.dataHandler.addLike(videoObject["objectId"] as String, button: sender as UIButton)
    }
    
    @IBAction func followButton(sender: AnyObject) {
        self.dataHandler.addFollower(videoObject["username"] as String, button: sender as UIButton)
    }
    
    @IBAction func reportButton(sender: AnyObject) {
        self.dataHandler.reportUser(videoObject["username"] as String, videoId: videoObject["objectId"] as String)
    }
    
    private func startPlaying() {
        let progress = JGProgressHUD(style: .Dark)
        progress.textLabel.text = "Loading"
        progress.showInView(self.view)
        
        let manager = PinVideoManager(videoView: self.videoView)
        let file = videoObject["video"] as PFFile
        manager.startPlayingWithVideoData(NSURL(string: file.url)!, completion: { () -> Void in
            manager.monitorTaps()
            progress.dismiss()
        })
    }
}