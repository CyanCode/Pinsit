//
//  SettingsViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/19/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import XLForm
import Parse

class SettingsViewController: XLFormViewController {
    var options: [String]!
    var set: SettingsData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.loginCheck(self)
        form = XLFormDescriptor(title: "Settings") //Main descriptor
        
        self.set = SettingsData(vc: self)
        self.createTableForm()
        set.checkUpgraded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        set.checkUpgraded()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        let row = self.form.formRowAtIndex(indexPath)
        
        switch row.tag as Tags.RawValue {
        case Tags.Upgrade.rawValue: set.upgradeAccount()
        case Tags.Email.rawValue: set.emailVerification()
            
        case Tags.Phone.rawValue: set.verify.verificationPressed()
        case Tags.PhoneNumDone.rawValue: set.verify.numberEntered()
        case Tags.PhoneCodeDone.rawValue: set.verify.codeEntered()
            
        case Tags.Logout.rawValue: set.logoutUser()
        case Tags.Delete.rawValue: set.deleteAccount()
        default: print("Disabled selection index")
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.selected = false
    }
    
    ///MARK: Settings form
    private func createTableForm() {
        //Form builder requirements
        var section: XLFormSectionDescriptor!
        var row: XLFormRowDescriptor!
        
        //"Pinsit" section
        if Upgrade().isUpgraded() == false {
            section = XLFormSectionDescriptor.formSectionWithTitle("Pinsit") as XLFormSectionDescriptor
            form.addFormSection(section)
            
            row = XLFormRowDescriptor(tag: Tags.Upgrade.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Upgrade Account")
            section.addFormRow(row)
        }
        
        let emailVer = PFUser.currentUser()!["emailVerified"] as? Bool
        let phoneVer = PFUser.currentUser()!["phone"] as? String
        
        //Verification section
        if (emailVer == nil || emailVer == false) || (phoneVer == nil || phoneVer! == "") {
            section = XLFormSectionDescriptor.formSectionWithTitle("Verification") as XLFormSectionDescriptor
            form.addFormSection(section)
            
            
            if emailVer == nil || emailVer == false {
                row = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Resend Email Verification")
                section.addFormRow(row)
            }
            
            if phoneVer == nil || phoneVer! == "" {
                row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Verify Phone Number")
                section.addFormRow(row)
                
                set.verify.section = section
            }
            
            //Phone verification credentials
            row = XLFormRowDescriptor(tag: Tags.PhoneNum.rawValue, rowType: XLFormRowDescriptorTypePhone)
            row.cellConfigAtConfigure.setObject("Phone Number", forKey: "textField.placeholder")
            row.value = ""
            row.hidden = true
            section.addFormRow(row)
            
            row = XLFormRowDescriptor(tag: Tags.PhoneNumDone.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Send Text Message")
            row.hidden = true
            section.addFormRow(row)
            
            row = XLFormRowDescriptor(tag: Tags.PhoneCode.rawValue, rowType: XLFormRowDescriptorTypeName)
            row.cellConfigAtConfigure.setObject("Verification Code", forKey: "textField.placeholder")
            row.value = ""
            row.hidden = true
            section.addFormRow(row)
            
            row = XLFormRowDescriptor(tag: Tags.PhoneCodeDone.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Confirm Phone Number")
            row.hidden = true
            section.addFormRow(row)
        }
        
        //Account section
        section = XLFormSectionDescriptor.formSectionWithTitle("Account") as XLFormSectionDescriptor
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: Tags.Logout.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Logout")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Delete.rawValue, rowType: XLFormRowDescriptorTypeButton, title: "Delete Account")
        section.addFormRow(row)
        
        self.form = form
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tos" {
            let vc = segue.destinationViewController as! TOSViewController
            vc.identifier = "settings"
        }
    }
}

enum Tags: String {
    case Upgrade = "upgrade"
    case Facebook = "facebook"
    case Twitter = "twitter"
    
    case Email = "email"
    case Phone = "phone"
    
    case PhoneNum = "phonenum"
    case PhoneNumDone = "phonenumdone"
    case PhoneCode = "phonecode"
    case PhoneCodeDone = "phonecodedone"
    
    case TOS = "tos"
    case Logout = "logout"
    case Delete = "delete"
}