//
//  CustomMessagesCollectionViewCellOutgoing.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2017/1/7.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import UIKit

class CustomMessagesCollectionViewCellOutgoing: CustomMessagesCollectionViewCell {
    
    
    @IBOutlet weak var reloadBTN: UIButton!
    
    @IBOutlet weak var reloadBtnContainer: UIView!
    
    @IBOutlet weak var reSending: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageBubbleTopLabel.textAlignment = NSTextAlignment.right
        self.cellBottomLabel.textAlignment = NSTextAlignment.right
    }
    
    override class func nib() -> UINib {
        return UINib(nibName: "CustomMessagesCollectionViewCellOutgoing", bundle: nil)
    }
    
    override class func cellReuseIdentifier() -> String {
        return "CustomMessagesCollectionViewCellOutgoing"
    }

}
