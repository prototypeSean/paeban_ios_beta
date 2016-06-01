//
//  Labels.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.

//  這是用來控制顯示「照片為本人」跟「性別」標籤用的

import UIKit

class Labels: UIView {
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 其實是不能按的，但是我不知道怎麼用UILabel放圖片，所以用UIButton..XD
        // 兩個標籤的物件建立出來等下用
        let t_ph_label = UIButton()
        let gender_label = UIButton()
    
        // 三個要用的圖片，先跟圖庫連喜來待用
        let truePhoto = UIImage(named: "True_photo")
        let fakePhoto = UIImage(named: "Fake_photo")
        let male = UIImage(named: "male")

        // 標籤的外框寬高 等下當參數調整位置用
        let labelHeight = Int(frame.size.height)
        let labelWidth = Int(frame.size.width)
        
        // 建立 打勾標籤 的框框跟位置 這邊y=6因為下面做了padding＝3，位置偏移
        let t_ph_label_Frame = CGRect(x: labelWidth/2 - labelHeight - 2, y: 3, width: labelHeight, height: labelHeight)
        // 建立完跟物件連起來
        t_ph_label.frame = t_ph_label_Frame
        t_ph_label.contentEdgeInsets = UIEdgeInsetsMake(1.5, 1.5, 1.5, 1.5)
        
        // 建立性別標籤的 框框跟位置
        let gender_label_frame = CGRect(x: labelWidth/2 + 2, y: 3, width: labelHeight, height: labelHeight)

        gender_label.frame = gender_label_frame
    gender_label.contentEdgeInsets = UIEdgeInsetsMake(1.5, 1.5, 1.5, 1.5)
        // 把圖片跟 標籤（其實是按鈕）物件連結起來，因為是按鈕，所以有 .Normal .Disabled等狀態
        t_ph_label.setImage(truePhoto,forState: .Normal)
        t_ph_label.setImage(fakePhoto, forState: .Disabled)
        gender_label.setImage(male,forState: .Normal)
        
        
        // 最後把位置圖片都做好的標籤載入
        addSubview(t_ph_label)
        addSubview(gender_label)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
