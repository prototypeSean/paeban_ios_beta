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
    
    var hashtagButtons = [UIButton]()
    //var tagListForCell = tagList
    var tagPostionDicKey = 0
    var tagListInContorller:[String]?
    // MARK: Initialization
    
    func drawButton(){
        print(tagListInContorller)
        var btn_x_start = 0
        if !tagListInContorller!.isEmpty{
            for x in 0..<tagListInContorller!.count {
                //tagPositionDic = [tagPostionDicKey as String:]
                
                let button = UIButton()
                button.titleLabel!.font = UIFont(name: "Arial Hebrew", size: 16)
                
                button.setTitle(tagListInContorller![x], forState: UIControlState.Normal)
                
                button.backgroundColor = UIColor.orangeColor()
                
                button.addTarget(self, action: #selector(HashTagsContorller.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
                
                // 先用一次魔法 讓按鈕的長寬都長出來
                button.sizeToFit()
                
                var buttonFrame = CGRect(x: 0, y: 0, width:button.frame.width + 4, height:button.frame.height - 6)
                
                // 我也不知道位啥上下顛倒
                button.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
                
                // 抓取按鈕起始位置 第一個從 0 開始
                buttonFrame.origin.x = CGFloat(btn_x_start)
                
                // 修改下一個按鈕起始位置 = 前一個位置＋現在按鈕寬度＋常數
                btn_x_start += Int(button.frame.width) + 12
                
                button.layer.cornerRadius = 3
                button.frame = buttonFrame
                addSubview(button)
            }
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //drawButton()
    }

    //  還沒作標籤太多太長的應對方式 （最多兩行，超過隱藏）

    func ratingButtonTapped(button: UIButton) {
        
        print("Button pressed 👍")
    }
}
