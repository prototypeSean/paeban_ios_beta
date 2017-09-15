//
//  ChangePasswordView.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/9/15.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordView:UIView{
    @IBOutlet var MainView: UIView!
        @IBOutlet weak var backgroundView: UIView!
        @IBOutlet weak var contenerView: UIView!
            @IBOutlet weak var old_password: UITextField!
            @IBOutlet weak var new_password_1: UITextField!
            @IBOutlet weak var new_password_2: UITextField!
            @IBOutlet weak var submit_btn_outlet: UIButton!
            @IBAction func submit_btn(_ sender: Any) {
                
            }
    
    var animate_time:TimeInterval = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        basic_setup()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        basic_setup()
    }
    
    func basic_setup(){
        // 基礎設定 類似view did load
        Bundle.main.loadNibNamed("ChangePassword", owner: self, options: nil)
        addSubview(MainView)
        self.MainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.MainView.frame = self.bounds
        style_setup()
        show_view_animate()
    }
    func style_setup(){
    }
    func show_view_animate(){
        UIView.animate(withDuration: 0, animations: {
            self.backgroundView.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.contenerView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (true) in
            UIView.animate(withDuration: self.animate_time, animations: {
                self.backgroundView.transform = CGAffineTransform.identity
                self.contenerView.transform = CGAffineTransform.identity
            })
        }
    }
}

















