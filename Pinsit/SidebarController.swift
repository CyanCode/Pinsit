//
//  SidebarController.swift
//  Pinsit
//
//  Created by Walker Christie on 12/13/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit

 @IBDesignable class SidebarController: UITabBarController, UITabBarControllerDelegate {
    var sidebar: FrostedSidebar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        tabBar.hidden = true
        
        sidebar = FrostedSidebar(itemImages: [
            UIImage(named: "map")!,
            UIImage(named: "post")!,
            UIImage(named: "following")!,
            UIImage(named: "account")!,
            UIImage(named: "settings")!
            ], colors: [
                UIColor(string: "#6C8672")!,
                UIColor(string: "#C4D4AF")!,
                UIColor(string: "#68A8AD")!,
                UIColor(string: "#737495")!,
                UIColor(string: "#F17D80")!
            ], selectedItemIndices: NSIndexSet(index: 0))
        
        sidebar.calloutsAlwaysSelected = true
        sidebar.isSingleSelect = false
        sidebar.showFromRight = true
        sidebar.actionForIndex = [
            0: {self.sidebar.dismissAnimated(true, completion: { finished in self.selectedIndex = 0}) },
            1: {self.sidebar.dismissAnimated(true, completion: { finished in self.selectedIndex = 1}) },
            2: {self.sidebar.dismissAnimated(true, completion: { finished in self.selectedIndex = 2}) },
            3: {self.sidebar.dismissAnimated(true, completion: { finished in self.selectedIndex = 3}) },
            4: {self.sidebar.dismissAnimated(true, completion: { finished in self.selectedIndex = 4}) }]
    }
    
    @IBInspectable var hiddenController: Bool = Bool() {
        didSet {
            self.tabBar.hidden = hiddenController
        }
    }
}
