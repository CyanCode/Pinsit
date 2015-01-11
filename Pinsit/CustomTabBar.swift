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
        tabBar.barTintColor = UIColor(string: "#242B2D")
        tabBar.tintColor = UIColor(string: "#FF2951")
        tabBar.selectedImageTintColor = UIColor(string: "#FF2951")
        
//        for item in (tabBar.items as [UITabBarItem]) {
//            let itemImg = item.image
//            
//        }
    }
}
