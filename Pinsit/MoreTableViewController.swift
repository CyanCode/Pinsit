//
//  MoreTableViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 8/1/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import StaticDataTableViewController
import Parse

class MoreTableViewController: StaticDataTableViewController {
    var manager: MoreManager!
    
    //Pinsit
    @IBOutlet var upgradeCell: UITableViewCell!

    //Verification
    @IBOutlet var resendEmailCell: UITableViewCell!
    @IBOutlet var verifyPhoneCell: UITableViewCell!
    @IBOutlet var phoneNumberEntryCell: UITableViewCell!
    @IBOutlet var sendTextCell: UITableViewCell!
    @IBOutlet var receivedCodeCell: UITableViewCell!
    @IBOutlet var checkCodeCell: UITableViewCell!
    
    //Fields
    @IBOutlet var phoneNumberField: UITextField!
    @IBOutlet var receivedCodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideSectionsWithHiddenRows = true
        self.manager = MoreManager(vc: self)
        self.manager.enableRequiredCells()
    }
    
    @IBAction func upgradePressed(sender: AnyObject) {
        Upgrade().startPurchase(self) { () -> Void in
            if Upgrade().isUpgraded() {
                self.cell(self.upgradeCell, setHidden: true)
            }
        }
    }
    
    @IBAction func resendEmailPressed(sender: AnyObject) {
        manager.emailVerification()
    }
    
    @IBAction func verifyPhonePressed(sender: AnyObject) {
        manager.numberVerify.verificationPressed()
    }
    
    @IBAction func sendTextPressed(sender: AnyObject) {
        manager.numberVerify.numberEntered()
    }
    
    @IBAction func checkCodePressed(sender: AnyObject) {
        manager.numberVerify.codeEntered()
    }
    
    @IBAction func logoutPressed(sender: AnyObject) {
        manager.logoutUser()
    }
    
    @IBAction func deleteAccountPressed(sender: AnyObject) {
        manager.deleteAccount()
    }
}

@IBDesignable class SettingsImageView: UIImageView {
    @IBInspectable var color: UIColor? {
        didSet {
            self.image = self.image!.imageWithRenderingMode(.AlwaysTemplate)
            self.tintColor = color
        }
    }
}

