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

@IBDesignable class MoreTableViewController: StaticDataTableViewController {
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
    
    @IBInspectable var headerTextColor: UIColor = UIColor.whiteColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideSectionsWithHiddenRows = true
        self.manager = MoreManager(vc: self)
        self.manager.enableRequiredCells()
    }
    
    //MARK: Buttons
    
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
    
    //MARK: overrides
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel.textColor = headerTextColor
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

@IBDesignable class SettingsTextField: UITextField {
    @IBInspectable var placeholderColor: UIColor = UIColor.whiteColor() {
        didSet {
            let text = self.placeholder == nil ? "" : self.placeholder!
            self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : placeholderColor])
        }
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

