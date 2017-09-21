//
//  ChangePasswordView.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/9/15.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordView:UIView, UITextFieldDelegate{
    // MARK: outlet
    @IBOutlet var MainView: UIView!
        @IBOutlet weak var backgroundView: UIView!
        @IBOutlet weak var contenerView: UIView!
            @IBOutlet weak var old_password: UITextField!
            @IBOutlet weak var new_password_1: UITextField!
                @IBOutlet weak var eye_1: UIButton!
            @IBOutlet weak var new_password_2: UITextField!
                @IBOutlet weak var eye_2: UIButton!
    
            @IBOutlet weak var submit_btn_outlet: UIButton!
    
    // MARK: action
    @IBAction func submit_btn(_ sender: Any) {
        submit_btn_press()
    }
    @IBAction func background_view_tap(_ sender: Any) {
        background_tap()
    }
    
    @IBAction func eye_1_press_down(_ sender: Any) {
        eye_1_press_down()
    }
    @IBAction func eye_1_release_inside(_ sender: Any) {
        eye_1_release()
    }
    @IBAction func eye_1_drag_outside(_ sender: Any) {
        eye_1_release()
    }
    
    @IBAction func eye_2_press_down(_ sender: Any) {
        eye_2_press_down()
    }
    @IBAction func eye_2_release_inside(_ sender: Any) {
        eye_2_release()
    }
    @IBAction func eye_2_drag_outside(_ sender: Any) {
        eye_2_release()
    }
    
    
    // MARK: vars
    var animate_time:TimeInterval = 0.4
    var load_view:UIView?
    var keybroad_showing = false
    var load_view_showing = false
    
    // MARK: sys required
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
        old_password.delegate = self
        new_password_1.delegate = self
        new_password_2.delegate = self
    }
    func style_setup(){
        //\u{1f441}
        eye_1.setTitle("ಠ_ಠ", for: .normal)
        eye_2.setTitle("ಠ_ಠ", for: .normal)
        new_password_1.isSecureTextEntry = true
        new_password_2.isSecureTextEntry = true
        old_password.placeholder = "舊密碼"
        new_password_1.placeholder = "新密碼"
        new_password_2.placeholder = "再次輸入新密碼" 
    }
    
    // MARK: press event
    func background_tap(){
        if keybroad_showing || load_view_showing{
            self.endEditing(true)
            keybroad_showing = false
        }
        else{
            self.removeFromSuperview()
        }
    }
    func submit_btn_press(){
        // 確認新密碼一致
        if new_password_1.text == new_password_2.text &&
            new_password_1.text != nil &&
            old_password.text != nil &&
            new_password_1.text != "" &&
            old_password.text != ""{
            let data_dic = [
                "user_id": userData.id!,
                "password": old_password.text!,
                "new_password": new_password_1.text!
            ]
            send_new_password_to_server(data_dic: data_dic as Dictionary<String, AnyObject>)
        }
        else{
            new_password_1.text = nil
            new_password_2.text = nil
            let alert = UIAlertController(title: "錯誤", message: "兩次輸入的密碼不一致", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            self.window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
    func eye_1_press_down(){
        new_password_1.isSecureTextEntry = false
    }
    func eye_1_release(){
        new_password_1.isSecureTextEntry = true
    }
    func eye_2_press_down(){
        new_password_2.isSecureTextEntry = false
    }
    func eye_2_release(){
        new_password_2.isSecureTextEntry = true
    }
    
    // MARK: interal func
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
    func send_new_password_to_server(data_dic:Dictionary<String, AnyObject>){
        let url = "sing_in/"
        add_load_view()
        HttpRequestCenter().http_request(url: url, data_mode: "change_password", form_data_dic: data_dic) { (result_dic:Dictionary<String, AnyObject>?) in
            DispatchQueue.main.async {
                self.endEditing(true)
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                if result_dic != nil{
                    self.dissmis_load_view()
                    if result_dic!["result"] as! String == "success"{
                        alert.title = "更改密碼"
                        alert.message = "密碼更換成功"
                        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (act) in
                            self.removeFromSuperview()
                        }))
                        socket.disconnect()
                    }
                    else{
                        alert.title = "錯誤"
                        alert.message = "密碼錯誤"
                        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: {(act) in
                            self.old_password.text = nil
                        }))
                    }
                    
                }
                else{
                    alert.title = "錯誤"
                    alert.message = "網路異常"
                    alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                    self.dissmis_load_view()
                }
                self.window?.rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keybroad_showing = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        keybroad_showing = false
        return true
    }
}
















