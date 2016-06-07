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
    

    
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        for _ in 0..<5 {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 25))
            button.backgroundColor = UIColor.orangeColor()
            
            button.addTarget(self, action: #selector(HashTagsContorller.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
            
            
            ratingButtons += [button]
            
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        var buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 25)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (44 + 5))
            button.frame = buttonFrame
            
            button.setTitle("123", forState: UIControlState.Normal)
        }
    }

    // MARK: Button Action
    func ratingButtonTapped(button: UIButton) {
        
        print("Button pressed 👍")
    }
}
