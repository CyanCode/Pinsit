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
        tabBar.barTintColor = UIColor(string: "#252B2D")
        tabBar.tintColor = UIColor(string: "#FF2951")
        tabBar.selectedImageTintColor = UIColor(string: "#FF2951")
        
        //Unselected text color
        let unselected = UIColor.whiteColor()
        let colorDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UITabBarItem.appearance().setTitleTextAttributes(colorDict as [NSObject : AnyObject], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes(colorDict as [NSObject : AnyObject], forState: .Selected)
        
        //Unselected image color
        for item in tabBar.items as! [UITabBarItem] {
            item.image = item.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        
        tabBarController?.selectedIndex = 0
    }
}
