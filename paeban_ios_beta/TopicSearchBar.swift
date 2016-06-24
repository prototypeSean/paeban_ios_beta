//
//  TopicSearchBar.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/6/24.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class TopicSearchBar: UISearchBar {
    
    var preferredFont: UIFont!
    
    var preferredTextColor: UIColor!
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        searchBarStyle = UISearchBarStyle.Prominent
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 要控制「搜尋框」，要先在這邊找到搜尋框在哪理，讓這個func傳回搜尋框是第幾個 subview
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKindOfClass(UITextField) {
                index = i
                break
            }
        }
        return index
    }
    
    override func drawRect(rect: CGRect) {
        
        // 找到那個要被修改的文字框
        if let index = indexOfSearchFieldInSubviews() {
            // 存到變數裡 subviews[0].subviews[index] 第0個 因為最外層是UIView，第二層的「第index個」才是我們要的
            let searchField: UITextField = subviews[0].subviews[index] as! UITextField
            
            // Set its frame.
            searchField.frame = CGRectMake(5.0, 5.0, frame.size.width - 20.0, frame.size.height - 10.0)
            
            // Set the font and text color of the search field.
            searchField.font = preferredFont
            searchField.textColor = UIColor.orangeColor()
//            searchField.attributedPlaceholder = NSAttributedString(string:"點擊搜尋 #關鍵字標籤", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            // Set the background color of the search field.
            searchField.backgroundColor = barTintColor
        }
        
        let startPoint = CGPointMake(0.0, frame.size.height)
        let endPoint = CGPointMake(frame.size.width, frame.size.height)
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1.0).CGColor
        shapeLayer.lineWidth = 1.5
        
        layer.addSublayer(shapeLayer)
        
        super.drawRect(rect)
    }
    
}
