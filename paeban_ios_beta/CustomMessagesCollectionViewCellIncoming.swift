//
//  CustomMessagesCollectionViewCellIncoming.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2017/1/7.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import UIKit

class CustomMessagesCollectionViewCellIncoming: CustomMessagesCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageBubbleTopLabel.textAlignment = NSTextAlignment.left
        self.cellBottomLabel.textAlignment = NSTextAlignment.left
    }
    
    override class func nib() -> UINib {
        return UINib(nibName: "CustomMessagesCollectionViewCellIncoming", bundle: nil)
    }
    
    override class func cellReuseIdentifier() -> String {
        return "CustomMessagesCollectionViewCellIncoming"
    }
}
