//
//  SettingsViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/19/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Social

class SettingsViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var upgrade: UITableViewCell!
    @IBOutlet var facebook: UITableViewCell!
    @IBOutlet var twitter: UITableViewCell!
    @IBOutlet var logout: UITableViewCell!
    @IBOutlet var removeAccount: UITableViewCell!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        self.tableView.delegate = self
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tapped = self.tableView.cellForRowAtIndexPath(indexPath)!
        
        switch tapped {
        case upgrade: upgradeAccount(); break
        case facebook: social(SocialType.Facebook); break
        case twitter: social(SocialType.Twitter); break
        case logout: logoutUser(); break
        case removeAccount: deleteAccount(); break
        default: break
        }
    }
    
    private func upgradeAccount() {
        
    }
    
    private func social(type: SocialType) {
        if type == SocialType.Twitter {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                var fb = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                fb.setInitialText("Follow me on Pinsit @" + PFUser.currentUser().username)
                self.presentViewController(fb, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Somethings Missing", message: "Make sure you have Facebook setup in your settings", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                var fb = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                fb.setInitialText("Follow me on Pinsit @" + PFUser.currentUser().username)
                self.presentViewController(fb, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Somethings Missing", message: "Make sure you have Twitter setup in your settings", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func logoutUser() {
        var user = PFUser.currentUser()
        user = nil
        StoryboardManager.segueRegistration(self)
    }
    
    private func deleteAccount() {
        
    }
}

enum SocialType {
    case Facebook
    case Twitter
}