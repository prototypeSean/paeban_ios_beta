//
//  RecentTableViewCell.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/8/31.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet var clientImg:UIImageView!
    @IBOutlet weak var isMyPic: UIImageView!
    @IBOutlet weak var clientSex: UIImageView!
    @IBOutlet weak var online: UIImageView!
    @IBOutlet weak var lastLine: UILabel!
    @IBOutlet weak var lastSpeaker: UILabel!
    @IBOutlet weak var hashtag: HashTagsContorller!
    @IBOutlet weak var ownerName: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
