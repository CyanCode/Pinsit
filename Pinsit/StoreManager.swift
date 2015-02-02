//
//  StoreManager.swift
//  Pinsit
//
//  Created by Walker Christie on 9/20/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class StoreManager: NSObject {
    var productID: NSString?
    var purchase: Purchase?
    var responseView: UIViewController
    
    init(responseV: UIViewController) {
        self.responseView = responseV
        self.productID = "com.walkerchristie.Pinit.Pro"
    }
    
    func startPurchase() {
        if (purchase != nil) {
            purchase = nil;
        }
        
        purchase = Purchase()
        purchase!.productID = productID
        purchase!.responderView = responseView
        
        purchase?.getProductID()
    }
    
    func purchaseItem() { //Formarly "purchase"
        purchase?.createPurchase()
    }

    func restore() {
        purchase?.restorePurchase()
    }
    
}