//
//  Designable.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/3.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

@IBDesignable class DesignableImageView: UIImageView { }
@IBDesignable class DesignableButton:UIButton { }
@IBDesignable class DesignableTextField:UITextField { }

// 整個app本地化的工具沒地方放暫放在這
// 用法：self.title = "設定".localized(withComment: "設定->導覽頁左上角文字")
extension String {
    func localized(withComment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
}
// 本地化的東西沒地方放暫放在這

// 讓故事版可以模擬CSS
extension UIView {
    @IBInspectable
    var borderWidth :CGFloat {
        get {
            return layer.borderWidth
        }
        
        set(newBorderWidth){
            layer.borderWidth = newBorderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get{
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) :nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var cornerRadius :CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue != 0
        }
    }
    
    @IBInspectable
    var makeCircular:Bool? {
        get{
            return nil
        }
        
        set {
            if let makeCircular = newValue , makeCircular {
                cornerRadius = min(bounds.width, bounds.height) / 2.0
            }
        }
    }
}
