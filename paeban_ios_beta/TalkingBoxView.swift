//
//  TalkingBoxView.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/9/12.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class TalkingBoxView:UIView, UITextFieldDelegate{
    // MARK setting
    var main_view_animate_time:TimeInterval = 0.4
    
    @IBOutlet var MainView: UIView!
        @IBOutlet weak var BackgroundView: UIView!
        @IBOutlet weak var ContenerView: UIView!
            @IBOutlet weak var mail_box_lable: UILabel!
            @IBOutlet weak var cancel_btn_outlet: UIButton!
            @IBOutlet weak var mail_text_filed: UITextField!
            @IBAction func BackgroundViewTap(_ sender: Any) {
        BackgroundViewTapDidPress()
    }
            @IBAction func reset_password(_ sender: Any) {
        reset_password_did_press()
    }
            @IBAction func resent_mail(_ sender: Any) {
        resent_mail_did_press()
    }
            @IBAction func cancel_btn_act(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    var ContenerViewInitCenter:CGPoint?
    var center_rect:CGRect?
    var keyborad_showing_state = false
    var load_view:UIView?
    var load_view_showing = false
    var BackgroundViewRect:CGRect?
    var ContenerViewRect:CGRect?
    var ContenerViewRectSubViewsRectList = [CGRect]()
    
    // MARK: override
    override init(frame: CGRect) {
        super.init(frame: frame)
        basic_setup()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        basic_setup()
    }
    
    // MARK: setting
    func basic_setup(){
        // 基礎設定 類似view did load
        Bundle.main.loadNibNamed("TalkingBox", owner: self, options: nil)
        addSubview(MainView)
        self.MainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.MainView.frame = self.bounds
        appeare_animate()
        style_setup()
        find_user_kb_height()
        mail_text_filed.delegate = self
        ContenerViewInitCenter = ContenerView.center
    }
    func style_setup(){
        // 設定風格專用
        //\u{2716}  <- 叉叉的unicode  但是用了就不能變色
        cancel_btn_outlet.setTitle("X", for: .normal)
        cancel_btn_outlet.setTitleColor(#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), for: .normal)
        cancel_btn_outlet.backgroundColor = #colorLiteral(red: 0.9899128079, green: 0.4874264598, blue: 0.2562194467, alpha: 1)
    }
    func appeare_animate(){
        UIView.animate(withDuration: 0, animations: {
            self.BackgroundView.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.ContenerView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (true) in
            UIView.animate(withDuration: self.main_view_animate_time, animations: {
                self.BackgroundView.transform = CGAffineTransform.identity
                self.ContenerView.transform = CGAffineTransform.identity
            })
        }
    }
    
    // MARK: press btn event
    func BackgroundViewTapDidPress(){
        if !keyborad_showing_state && !load_view_showing{
            self.removeFromSuperview()
        }
        else{
            self.dismissKeyboard()
        }
    }
    func reset_password_did_press(){
        self.endEditing(true)
        add_load_view()
        let send_dic = ["email":mail_text_filed.text]
        HttpRequestCenter().http_request(
            url: "sing_in/",
            data_mode: "reset_password",
            form_data_dic: send_dic as Dictionary<String, AnyObject>) { (result_dic:Dictionary<String, AnyObject>?) in
                DispatchQueue.main.async {
                    self.dissmis_load_view()
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                    if result_dic != nil{
                        if result_dic!["result"] as! String == "check_success"{
                            alert.title = "請收信"
                            alert.message = "已將新密碼發送到您的註冊信箱"
                            self.removeFromSuperview()
                        }
                        else{
                            alert.title = "哎呀 ！"
                            alert.message = "找不到該用戶，請確認信箱是否正確"
                        }
                    }
                    else{
                        alert.title = "哎呀 ！"
                        alert.message = "網路發生異常"
                    }
                    self.window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
                }
        }
    }
    func resent_mail_did_press(){
        self.endEditing(true)
        add_load_view()
        let send_dic = ["email":mail_text_filed.text]
        HttpRequestCenter().http_request(
            url: "sing_in/",
            data_mode: "resend_mail",
            form_data_dic: send_dic as Dictionary<String, AnyObject>) { (result_dic:Dictionary<String, AnyObject>?) in
                DispatchQueue.main.async {
                    self.dissmis_load_view()
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                    if result_dic != nil{
                        if result_dic!["result"] as! String == "check_success"{
                            alert.title = "請收信"
                            alert.message = "已將認證網址發送到您的註冊信箱"
                            self.removeFromSuperview()
                        }
                        else{
                            alert.title = "哎呀 ！"
                            alert.message = "找不到該用戶，請確認信箱是否正確"
                        }
                    }
                    else{
                        alert.title = "哎呀 ！"
                        alert.message = "網路發生異常"
                    }
                    self.window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    // MARK: tool function
    func add_load_view(){
        load_view = UIView()
        load_view?.frame = self.MainView.frame
        let load_view_simbo = UIActivityIndicatorView()
        load_view_simbo.center = self.MainView.center
        load_view_simbo.color = UIColor.gray
        load_view?.addSubview(load_view_simbo)
        self.addSubview(load_view!)
        load_view_simbo.startAnimating()
        load_view_showing = true
    }
    func dissmis_load_view(){
        load_view?.removeFromSuperview()
        load_view_showing = false
    }
    
    // MARK: keyborad control
    func find_user_kb_height(){
        // 設定監聽鍵盤
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.dismissKeyboard))
        self.addGestureRecognizer(tap)
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !keyborad_showing_state{
                ContenerView.center.y += keyboardSize.height
                keyborad_showing_state = true
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            ContenerView.center = ContenerViewInitCenter!
            keyborad_showing_state = false
        }
    }
    func dismissKeyboard(){
        mail_text_filed.endEditing(true)
    }
    
    // MARK: text field delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}












