//
//  CustomTabBar.swift
//  Pinsit
//
//  Created by Walker Christie on 1/3/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBarController {
    override func viewDidLoad() {
        //Bar background color
        tabBar.barTintColor = UIColor(string: "#2F343B")
        
        //Selected tint color
        tabBar.tintColor = UIColor.whiteColor()
        
        //Unselected image color
        for item in tabBar.items! as! [UITabBarItem] {
            item.image = item.selectedImage.imageWithColor(UIColor(string: "#7E827A")).imageWithRenderingMode(.AlwaysOriginal)
        }
                
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(string: "#7E827A")], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Selected)
        
        tabBarController?.selectedIndex = 0
    }
}
