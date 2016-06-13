//
//  HashTagsContorller.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/6/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
var ccc:[String] = []
class HashTagsContorller: UIView {
    
    // MARK: Properties
    
    var rating = 0
    var ratingButtons = [UIButton]()
    //var tagListForCell = tagList
    var tagPostionDicKey = 0
    var tagListInContorller:[String]{
        get{
            return tagList
        }
    }
    // MARK: Initialization

    func drawButton(){
        var actually_btn_width = 0
        for x in 0..<tagListInContorller.count {
            //tagPositionDic = [tagPostionDicKey as String:]
            
            let button = UIButton()
            button.titleLabel!.font = UIFont(name: "Arial Hebrew", size: 16)

            button.setTitle(tagListInContorller[x], forState: UIControlState.Normal)
            
            button.backgroundColor = UIColor.orangeColor()
            
            button.addTarget(self, action: #selector(HashTagsContorller.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
            
            // 先用一次魔法 讓按鈕的長寬都長出來
            button.sizeToFit()
            
            var buttonFrame = CGRect(x: 0, y: 0, width:button.frame.width + 4, height:button.frame.height - 6)
            
            // 我也不知道位啥上下顛倒
            button.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
            
            // 這邊可以抓到目前這個按鈕的寬度
            
            
            // 每個按鈕的 x 位置都要重劃
            // 第一個 ＝ 0 + 常數
            // 第二個 ＝ 前一個寬度 ＋ 常數
            buttonFrame.origin.x = CGFloat(actually_btn_width)
            
            actually_btn_width += Int(button.frame.width) + 10
            print(actually_btn_width)
            
            button.layer.cornerRadius = 3
            button.frame = buttonFrame
            addSubview(button)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawButton()
    }

    
//    override func layoutSubviews() {
//        var buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 25)
//        
//        // Offset each button's origin by the length of the button plus spacing.
//        var tagCount = 0
//        print("2")
//        for (index, button) in ratingButtons.enumerate() {
//            //print("index")
//            print("3")
//            buttonFrame.origin.x = CGFloat(index * (44 + 5))
//            button.frame = buttonFrame
//            let tagText = "123"
//                        //print(tagListForCell)
////            if tagListForCell.count > tagCount{
////                print(tagListForCell)
////                tagText = tagListForCell[tagCount]
////            }
//            
//            button.setTitle(tagText, forState: UIControlState.Normal)
//            tagCount += 1
//        }
//    }

    // MARK: Button Action
    func ratingButtonTapped(button: UIButton) {
        
        print("Button pressed 👍")
    }
}
