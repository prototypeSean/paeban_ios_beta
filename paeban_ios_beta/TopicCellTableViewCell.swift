//
//  TopicCellTableViewCell.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/5.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit


class TopicCellTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var topicTitle: UILabel!
    
    @IBOutlet weak var topicOwnerImage: UIImageView!
    
    @IBOutlet weak var labels: Labels!
        
    @IBOutlet weak var hashtags: HashTagsContorller!
    
    @IBOutlet weak var isMe: UIImageView!
    
    @IBOutlet weak var sex: UIImageView!
    
    @IBOutlet weak var online: UIImageView!
    
    // 記得控制的時候要用sizeToFit()讓他自動調整長度
    @IBOutlet weak var topicOwner: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let myPhotoLayer:CALayer = topicOwnerImage.layer
        myPhotoLayer.masksToBounds = true
        myPhotoLayer.cornerRadius = 9
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}


class UILabelPadding : UILabel {
    
    fileprivate var padding = UIEdgeInsets.zero
    
    @IBInspectable
    var paddingLeft: CGFloat {
        get { return padding.left }
        set { padding.left = newValue }
    }
    
    @IBInspectable
    var paddingRight: CGFloat {
        get { return padding.right }
        set { padding.right = newValue }
    }
    
    @IBInspectable
    var paddingTop: CGFloat {
        get { return padding.top }
        set { padding.top = newValue }
    }
    
    @IBInspectable
    var paddingBottom: CGFloat {
        get { return padding.bottom }
        set { padding.bottom = newValue }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = self.padding
        var rect = super.textRect(forBounds: UIEdgeInsetsInsetRect(bounds, insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x    -= insets.left
        rect.origin.y    -= insets.top
        rect.size.width  += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
    
}
