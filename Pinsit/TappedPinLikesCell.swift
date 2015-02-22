//
//  TappedPinLikesCell.swift
//  Pinsit
//
//  Created by Walker Christie on 2/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class TappedPinLikesCell: UITableViewCell {
    @IBOutlet var username: UILabel!
    @IBOutlet var profileImage: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
