//
//  VideoViewForm.swift
//  Pinsit
//
//  Created by Walker Christie on 4/5/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class VideoViewForm: XLFormViewController {
    var likesSection: XLFormSectionDescriptor!
    
    override init!(form: XLFormDescriptor!) {
        super.init(form: form)
        createForm()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createForm() {
        var section: XLFormSectionDescriptor
        var row: XLFormRowDescriptor
        
        XLFormViewController.cellClassesForRowDescriptorTypes().setObject("VideoButtonsCell", forKey: CustomXLFormDescriptorType.Components.rawValue)
        XLFormViewController.cellClassesForRowDescriptorTypes().setObject("DescriptionCell", forKey: CustomXLFormDescriptorType.Description.rawValue)
        XLFormViewController.cellClassesForRowDescriptorTypes().setObject("LikesCell", forKey: CustomXLFormDescriptorType.Likes.rawValue)
        
        form = XLFormDescriptor(title: "Video View")
        
        section = XLFormSectionDescriptor.formSection() as! XLFormSectionDescriptor
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: "comp", rowType: CustomXLFormDescriptorType.Components.rawValue, title: "")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "description", rowType: CustomXLFormDescriptorType.Description.rawValue, title: "")
        section.addFormRow(row)
        
        likesSection = XLFormSectionDescriptor.formSection() as! XLFormSectionDescriptor
        form.addFormSection(likesSection)
    }
}

enum CustomXLFormDescriptorType: String {
    case Components = "components"
    case Description = "description"
    case Likes = "likes"
}