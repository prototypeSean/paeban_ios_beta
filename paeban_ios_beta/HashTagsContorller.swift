//
//  HashTagsContorller.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/6/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class HashTagsContorller: UIView {
    
    // MARK: Properties
    
    var rating = 0
    var ratingButtons = [UIButton]()
    var tagListForCell = tagList
    var tagPositionDic:[String:[String]] = [:]
    var tagPostionDicKey = 0
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        for _ in 0..<5 {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 8))
            button.backgroundColor = UIColor.orangeColor()
            
            button.addTarget(self, action: #selector(HashTagsContorller.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
            
            
            ratingButtons += [button]
            
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        var buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 8)
        
        // Offset each button's origin by the length of the button plus spacing.
        var tagCount = 0
        print("2")
        for (index, button) in ratingButtons.enumerate() {
            print("index")
            print(index)
            buttonFrame.origin.x = CGFloat(index * (44 + 5))
            button.frame = buttonFrame
            let tagText = "123"
                        //print(tagListForCell)
//            if tagListForCell.count > tagCount{
//                print(tagListForCell)
//                tagText = tagListForCell[tagCount]
//            }
            
            button.setTitle(tagText, forState: UIControlState.Normal)
            tagCount += 1
        }
    }

    // MARK: Button Action
    func ratingButtonTapped(button: UIButton) {
        
        print("Button pressed 👍")
    }
}
