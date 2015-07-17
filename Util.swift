//
//  Util.swift
//  Pinsit
//
//  Created by Walker Christie on 7/8/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation

extension PFQuery {
    func findAndDeleteObjects() throws {
        do {
            for object in try findObjectsWithError() {
                let obj = object as PFObject
                try obj.deleteWithError()
            }
        } catch let error as NSError {
            throw error
        }
    }
}

extension UIImage {
    func resize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension NSNumber {
    func randomNumberInRange(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(min - max + 1)))
    }
}

extension PFUser {
    class func getProfileImage() -> PFFile {
        if PFUser.currentUser()!["profileImage"] != nil {
            return PFUser.currentUser()!["profileImage"] as! PFFile
        } else {
            let image = UIImage(named: "profile")
            let data = UIImagePNGRepresentation(image!)
            return PFFile(data: data!)
        }
    }
}

extension UIView {
    class func detailViewFromNib() -> PostDetailsView {
        return UINib(nibName: "PostDetailsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PostDetailsView
    }
    
    ///Inserts layer into view, checking if others exist and deleting them
    ///
    ///- parameter toInsert: layer to insert
    func insertLayerWithCheck(toInsert: CALayer) {
        let sublayers = self.layer.sublayers
        
        if sublayers != nil && (sublayers!).count > 0 {
            sublayers![0].removeFromSuperlayer()
        }
        
        self.layer.insertSublayer(toInsert, atIndex: 0)
    }
    
    func insertLayerAtTop(toInsert: CALayer) {
        let index = self.layer.sublayers != nil ? self.layer.sublayers!.count + 1 : 0
        
        self.layer.insertSublayer(toInsert, atIndex: UInt32(index))
    }
}

extension UILabel {
    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
}

extension String {
    func base64Encode() -> String {
        let plainData = dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let base = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        return base!
    }
    
    func base64Decode() -> String? {
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let decodedString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        return decodedString as String?
    }
}