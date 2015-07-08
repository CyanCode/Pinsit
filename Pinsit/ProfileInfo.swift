//
//  ProfileInfo.swift
//  Pinsit
//
//  Created by Walker Christie on 6/25/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class ProfileInfo: UIView {
    @IBOutlet var desc: UILabel!
    @IBOutlet var profile: UIImageView!
    private var statsHeight: CGFloat!
    private var fullDesc: NSMutableAttributedString?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.statsHeight = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.statsHeight = 0
    }
    
    func loadDescriptionWithUsername(username: String, description: String) {
        self.desc.attributedText = NSAttributedString(string: description)
        
        Async.background {
            var user: PFUser!
            
            if self.fullDesc == nil {
                let query = PFUser.query()!
                query.whereKey("username", equalTo: username)
                
                do {
                    user = try query.findObjectsWithError()[0] as! PFUser
                } catch {
                    return
                }

                //Karma Level
                let karma = user["karma"] as! NSNumber
                var karmaNum = NSMutableAttributedString(string: karma.description)
                
                karmaNum.beginEditing()
                karmaNum.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(16), range: NSMakeRange(0, karmaNum.length))
                karmaNum.addAttribute(NSForegroundColorAttributeName, value: UIColor(string: "#253E46"), range: NSMakeRange(0, karmaNum.length))
                karmaNum.endEditing()
                
                let karmaAppend = NSMutableAttributedString(string: "Karma Level ")
                karmaAppend.appendAttributedString(karmaNum)
                karmaNum = karmaAppend
                
                //Date Posted (calculate months)
                let startDate = user.createdAt!
                let endDate = NSDate()
                let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                let comps = gregorian!.components(NSCalendarUnit.Month, fromDate: startDate, toDate: endDate, options: [])
                let months: String = comps.month > 1 ? "\(comps.month) Months" : "1 Month"
                let dateAttr = NSMutableAttributedString(string: "User For \(months)\n")
                dateAttr.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(16), range: NSMakeRange("User For ".characters.count, comps.month.description.characters.count))
                
                //Create full attributes
                self.fullDesc = NSMutableAttributedString(attributedString: dateAttr)
                self.fullDesc!.appendAttributedString(karmaNum)
                self.fullDesc!.appendAttributedString(NSMutableAttributedString(string: "\n" + description))
            }
            
            Async.main {
                self.desc.attributedText = self.fullDesc!
                self.statsHeight = self.desc.heightForView("Karma Level X", font: UIFont.boldSystemFontOfSize(14), width: self.desc.frame.width)
                self.adjustSize()
            }
        }
    }
    
    func loadProfileWithUsername(username: String) {
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: username)
        
        query.findObjectsInBackgroundWithBlock { (object, error) -> Void in
            if error == nil && object != nil {
                let objs = object as! [PFObject]
                let file = objs[0]["profileImage"] as? PFFile
                
                if file != nil {
                    self.profile.image = UIImage(data: file!.getData()!)
                } else {
                    self.profile.image = UIImage(named: "profile.png")
                }
            } else {
                self.profile.image = UIImage(named: "profile.png")
            }
        }
    }
    
    func adjustSize() {
        let height = desc.heightForView(desc.text!, font: desc.font, width: desc.frame.width)
        desc.frame.size.height = height + statsHeight
        
        if height + 16 > 75 {
            self.frame.size.height = height + 16
        }
    }
    
    static func loadViewFromNib() -> ProfileInfo {
        return NSBundle.mainBundle().loadNibNamed("ProfileInfo", owner: self, options: nil).first as! ProfileInfo
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