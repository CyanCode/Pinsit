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
        tabBar.barTintColor = UIColor(string: "#252B2D") //Dark-Gray
        tabBar.tintColor = UIColor(string: "#A3BDC6") //Lightblue-white
        tabBar.selectedImageTintColor = UIColor(string: "#A3BDC6") //Lightblue-white
        //Old pink-red: FF2951
        
        //Unselected text color
        let unselected = UIColor.whiteColor()
        let colorDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        //UITabBarItem.appearance().setTitleTextAttributes(colorDict as [NSObject : AnyObject], forState: UIControlState.Normal)
        //UITabBarItem.appearance().setTitleTextAttributes(colorDict as [NSObject : AnyObject], forState: .Selected)
        
        //Unselected image color
        for item in tabBar.items! as [UITabBarItem] {
            item.image = item.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        
        tabBarController?.selectedIndex = 0
    }
}
