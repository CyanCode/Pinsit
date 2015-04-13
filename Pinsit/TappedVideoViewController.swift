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
    @IBOutlet var tableView: PinVideoTableView!
    
    var videoObject: PFObject!
    private var dataHandler: PinVideoData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
        AppDelegate.loginCheck(self)
        self.startPlaying()
        self.dataHandler = PinVideoData(viewController: self)
        self.tableView.readyTableView(videoObject)
    }
    
    @IBAction func downloadButton(sender: AnyObject) {
        self.dataHandler.downloadVideo()
    }
    
    @IBAction func likeVideoButton(sender: AnyObject) {
        self.dataHandler.addLike(videoObject.objectId!, button: sender as! UIButton)
    }
    
    @IBAction func followButton(sender: AnyObject) {
        self.dataHandler.addFollower(videoObject["username"] as! String, button: sender as! UIButton)
    }
    
    @IBAction func reportButton(sender: AnyObject) {
        self.dataHandler.reportUser(videoObject["username"] as! String, videoId: videoObject.objectId!)
    }
        
    private func startPlaying() {
        let progress = JGProgressHUD(style: .Dark)
        progress.textLabel.text = "Loading"
        progress.showInView(self.view)
        
        let manager = PinVideoManager(videoView: self.videoView)
        
        VideoManager(object: videoObject).pullVideoData { (data) -> Void in
            if data != nil {
                manager.startPlayingWithVideoData(data!, completion: { () -> Void in
                    manager.monitorTaps()
                    progress.dismiss()
                })
            } else {
                println("Could not retrieve video data!")
            }
        }
    }
    
    private func getVideoData(object: PFObject, completion: (data: NSData?) -> Void) {
        if VideoCache().pinExistsInCache(object["objectId"] as! String) == true {
            let pin = VideoCache().getPinWithId(videoObject!["objectId"] as! String)
            let file = pin["videoData"] as? PFFile
            
            completion(data: file?.getData())
        } else {
            let video = object["video"] as! String
            let id = object["objectId"] as! String
            
            VideoCache().cacheDataFromServer(id, file: object["video"] as! PFFile, completion: { (data) -> Void in
                completion(data: data)
            })
        }
    }
}