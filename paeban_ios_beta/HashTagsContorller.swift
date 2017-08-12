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
    var ratingButtons = [UIButton]()
    //var tagListForCell = tagList
    var tagPostionDicKey = 0
    var tagListInContorller:[String]?
    // MARK: Initialization
    
    func drawButton(){
        var btn_x_start = 0
        if !tagListInContorller!.isEmpty{
            if self.subviews.count >= 0{
                for view in self.subviews{
                    view.removeFromSuperview()
                }
                for x in 0..<tagListInContorller!.count {
                    //tagPositionDic = [tagPostionDicKey as String:]
                    
                    let button = UIButton()
                    button.titleLabel!.font = UIFont(name: "Arial Hebrew", size: 11)
                    
                    button.setTitle(tagListInContorller![x], for: UIControlState())
                    
                    button.backgroundColor = UIColor.orange
                    
                    button.addTarget(self, action: #selector(HashTagsContorller.ratingButtonTapped(_:)), for: .touchDown)
                    
                    // 先用一次魔法 讓按鈕的長寬都長出來
                    button.sizeToFit()
                    
                    var buttonFrame = CGRect(x: 0, y: 0, width:button.frame.width + 4, height:button.frame.height - 5)
                    
                    // 我也不知道位啥上下顛倒
                    button.contentVerticalAlignment = UIControlContentVerticalAlignment.top
                    
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
        else{
            for view in self.subviews{
                view.removeFromSuperview()
            }
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //drawButton()
    }

    //  還沒作標籤太多太長的應對方式 （最多兩行，超過隱藏）

    func ratingButtonTapped(_ button: UIButton) {
        // fly "這函數他媽又是幹嘛用的"
    }
}
