//
//  FriendInvitedListTableViewCell.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/25.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class FriendInvitedListTableViewCell: UITableViewCell {

    @IBOutlet weak var invited_count: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
