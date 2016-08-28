//
//  MyTopicTableViewCell.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class MyTopicTableViewCell: UITableViewCell {

    @IBOutlet weak var topicTitle: UILabel!
    @IBOutlet weak var unReadS: UILabel!
    @IBOutlet weak var unReadM: UILabel!
    
    @IBOutlet weak var topicTableDetail: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
