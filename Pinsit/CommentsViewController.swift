//
//  CommentsViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 8/20/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import DZNEmptyDataSet

class CommentsViewController: PFQueryTableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    let identifier = "CommentsTableViewCell"
    var videoId = ""
    
    override func queryForTable() -> PFQuery {
        return PFQuery(className: "Comments").whereKey("videoId", equalTo: videoId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        tableView.reloadEmptyDataSet()
    }
    
    override func objectsWillLoad() {
        tableView.reloadEmptyDataSet()
        super.objectsWillLoad()
    }
    
    ///MARK: Tableview
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! CommentsTableViewCell
        
        cell.username = object!["username"] as! String
        cell.profileImage.username = object!["username"] as! String
        cell.commentLabel.text = object!["comment"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let maxHeight = CGFloat(2000)
        let font = UIFont.systemFontOfSize(14.0)
        let text = (objects! as! [PFObject])[indexPath.row]["comment"] as! NSString
        let height = text.boundingRectWithSize(CGSizeMake(tableView.frame.size.width, maxHeight), options: .UsesLineFragmentOrigin | .UsesFontLeading, attributes: [NSFontAttributeName : font], context: nil).size.height
        
        return height >= 64 ? height : 64
    }
    
    ///MARK: Empty DataSet
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSMutableAttributedString(string: "This post has no comments", attributes: [NSFontAttributeName : UIFont(name: "Helvetica", size: 15)!])
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(text.string)))
        
        return text
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}

@IBDesignable class CommentsTableViewCell: PFTableViewCell {
    var username: String!
    @IBOutlet var profileImage: FollowerImageView!
    @IBOutlet var commentLabel: UILabel!
}