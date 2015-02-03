//
//  FollowersCell.swift
//  Pinsit
//
//  Created by Walker Christie on 2/2/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class FollowersCell: PFTableViewCell {
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var followerButton: UIButton!
    var isFollowing: Bool!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isFollowing = false
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
