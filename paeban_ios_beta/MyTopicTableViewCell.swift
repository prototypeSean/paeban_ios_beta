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
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            
        } else {
            self.alpha = 1.0
        }
    }
    
    //MARK: 點父框字會亮
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        // changing text color
        self.topicTitle.textColor = selected ?  UIColor(red:0.97, green:0.44, blue:0.34, alpha:1.0) : UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.0)
        self.topicTitle.shadowColor = selected ?UIColor.white : UIColor.clear
        self.topicTitle.shadowOffset = CGSize.init(width: 0, height: 0)
        
        
            let gradientBackgroundColors = [UIColor(red:0.97, green:0.97, blue:0.96, alpha:1.0).cgColor, UIColor.white.cgColor,UIColor(red:0.97, green:0.97, blue:0.96, alpha:1.0).cgColor]
            let gradientLocations = [0.0,1.0,0.0]
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientBackgroundColors
            gradientLayer.locations = gradientLocations as [NSNumber]?
            
            gradientLayer.frame = self.bounds
            let backgroundView = UIView(frame: self.bounds)
            backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            
            self.backgroundView = backgroundView
        

        
    }
}
