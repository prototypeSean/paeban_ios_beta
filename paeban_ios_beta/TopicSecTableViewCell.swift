//
//  TopicSecTableViewCell.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/7/9.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class TopicSecTableViewCell: UITableViewCell {

    @IBOutlet weak var clientName: UILabel!
    @IBOutlet weak var speaker: UILabel!
    @IBOutlet weak var lastLine: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var isTruePhoto: UIImageView!
    @IBOutlet weak var sexLogo: UIImageView!
    @IBOutlet weak var onlineLogo: UIImageView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
