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
    @IBOutlet var viewsLabel: UILabel!
    @IBOutlet var downloadsLabel: UILabel!
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var videoDescription: UITextView!
    
    override func viewDidAppear(animated: Bool) {
        AppDelegate.loginCheck(self)
    }
    
    @IBAction func downloadButton(sender: AnyObject) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    //    let vc =
    }
}