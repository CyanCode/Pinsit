//
//  SettingsViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/19/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class SettingsViewController: XLFormViewController {
    var options: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.loginCheck(self)
        
        self.createTableForm()
    }
    
    ///MARK: Button Selectors
    private func upgradeAccount() {
        Upgrade().startPurchase(self)
    }
    
    private func social(type: SocialType) {
        let manager = SocialManager(vc: self)
        manager.displayShareDialog(type)
    }
    
    private func logoutUser() {
        PFUser.logOut()
        StoryboardManager.segueRegistration(self)
    }
    
    private func deleteAccount() {
        
    }
    
    private func emailVerification() {
        let recover = RecoverAccount(vc: self)
        recover.reverifyEmailAddress { () -> Void in
            println("Finished verifying email")
        }
    }
    
    private func numberVerification() {
        let recover = RecoverAccount(vc: self)
        recover.reverifyPhoneNumber { () -> Void in
            println("Finished verifying phone")
        }
    }
    
    private func showTermsOfService() {
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = self.form.formRowAtIndex(indexPath)
        
        switch row.tag as Tags.RawValue {
        case Tags.Upgrade.rawValue: self.upgradeAccount()
        case Tags.Facebook.rawValue: self.social(.Facebook)
        case Tags.Twitter.rawValue: self.social(.Twitter)
        case Tags.Email.rawValue: self.emailVerification()
        case Tags.Phone.rawValue: self.numberVerification()
        case Tags.TOS.rawValue: self.showTermsOfService()
        case Tags.Logout.rawValue: self.logoutUser()
        case Tags.Delete.rawValue: self.deleteAccount()
        default: println("Selection index error")
        }
    }
    
    ///MARK: Settings form
    private func createTableForm() {
        //Form builder requirements
        var section: XLFormSectionDescriptor!
        var row: XLFormRowDescriptor!
        
        form = XLFormDescriptor(title: "Settings") //Main descriptor
        
        //"Pinsit" section
        section = XLFormSectionDescriptor.formSectionWithTitle("Pinsit") as XLFormSectionDescriptor
        form.addFormSection(section)
        
        if Upgrade().isUpgraded() == false {
            row = XLFormRowDescriptor(tag: Tags.Upgrade.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Upgrade Account")
            section.addFormRow(row)
        }
        
        row = XLFormRowDescriptor(tag: Tags.Facebook.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Share on Facebook")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Twitter.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Share on Twitter")
        section.addFormRow(row)
        
        //Verification section
        section = XLFormSectionDescriptor.formSectionWithTitle("Verification") as XLFormSectionDescriptor
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Resend Email Verification")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Resend Number Verification")
        section.addFormRow(row)
        
        //Account section
        section = XLFormSectionDescriptor.formSectionWithTitle("Account") as XLFormSectionDescriptor
        form.addFormSection(section)
        row = XLFormRowDescriptor(tag: Tags.TOS.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Terms of Service")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Logout.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Logout")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Delete.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Delete Account")
        section.addFormRow(row)
        
        self.form = form
    }
}

enum Tags: String {
    case Upgrade = "upgrade"
    case Facebook = "facebook"
    case Twitter = "twitter"
    case Email = "email"
    case Phone = "phone"
    case TOS = "tos"
    case Logout = "logout"
    case Delete = "delete"
}