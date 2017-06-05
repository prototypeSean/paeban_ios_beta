//
//  SettingViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/10/17.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
import Starscream

class SettingViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var isTruePhotoSwitch: UISwitch!

    @IBOutlet weak var isTruePhoto: UIImageView!
    @IBAction func logOutBtn(_ sender: AnyObject) {
        logOut()
    }
    @IBOutlet weak var pencilIcon: UIImageView!
    // 本人照片開關控制勾勾圖示出現與否
    @IBAction func switchChanged(_ sender: AnyObject) {
        if isTruePhotoSwitch.isOn {
            print("on")
            
            isTruePhoto.tintColor = UIColor(red:0.00, green:0.73, blue:0.62, alpha:1.0)
        }
        else {
            print("off")
            isTruePhoto.tintColor = UIColor.clear
        }
    }
    
    @IBAction func text_change(_ sender: UITextField) {
        if sender.text != nil{
            change_name_btn_text(text: sender.text!)
        }
        
    }
    @IBOutlet weak var name_text: UITextField!
    @IBAction func name_btn(_ sender: AnyObject) {
        edit_name()
    }
    @IBOutlet weak var name_btn_obj: UIButton!
    

    @IBOutlet weak var is_true_photo_switch: UISwitch!
    @IBAction func save_btn(_ sender: AnyObject) {
        save_data_to_server()
    }
    
    @IBAction func reset_act(_ sender: Any) {
        let send_dic = [
            "msg_type":"cmd",
            "text":"test3"
        ]
        socket.write(data: json_dumps(send_dic as NSDictionary))
    }
    
    var initFearm:CGRect?
    var initCenter:CGPoint?
    var selectedField:UIButton?
    
    override func viewDidAppear(_ animated: Bool) {
        initFearm = self.view.frame
        initCenter = self.view.center
    }
    
    func find_user_kb_height(){
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let Center_1 = (((initFearm?.height)! - keyboardSize.height))/2
            let delta_x = ((name_btn_obj!.center.y)) - Center_1
            var newCenter_y = (initCenter?.y)! - delta_x
            if delta_x > keyboardSize.height{
                newCenter_y = (initCenter?.y)! - keyboardSize.height
            }
            self.view.center = CGPoint(x: self.view.center.x, y: newCenter_y)
        }
    }
    var kb_h:CGFloat = 64
    
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.center = self.initCenter!
        }
    }
    // internal func
    override func viewWillAppear(_ animated: Bool) {
        if userData.is_real_photo == true{
            isTruePhotoSwitch.isOn = true
        }
    }
    func logOut(){
        HttpRequestCenter().request_user_data("log_out", send_dic: [:]) { (element) in
            //nil
        }
        cookie_new.reset_cookie()
        myFriendsList = []
        logInState = false
        firstConnect = true
        socket.disconnect()
        fbLoginManager.logOut()
        let session = URLSession.shared
        session.finishTasksAndInvalidate()        
        session.reset {
            DispatchQueue.main.async(execute: {
                if let navc = self.parent?.parent?.parent as? UINavigationController{
                    navc.popToRootViewController(animated: true)
                }
                
            })
        }
    }
    func edit_name(){
        name_text.becomeFirstResponder()
    }
    func change_name_btn_text(text:String){
        name_btn_obj.setTitle(text, for: UIControlState.normal)
    }
    func resizeImage1(image: UIImage, newWidth: CGFloat) -> UIImage {
        let jpegImgData = UIImageJPEGRepresentation(image, CGFloat(1))
        let jpegImg = UIImage(data: jpegImgData!)
        let scale = newWidth / jpegImg!.size.width
        let newHeight = jpegImg!.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        jpegImg!.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let img2 = UIImage(data: UIImageJPEGRepresentation(newImage!, CGFloat(0.7))!)
        return img2!
    }
    func save_data_to_server(){
        let load_view = add_loading_view()
        DispatchQueue.global(qos: .background).async {
            sleep(30)
            if load_view != nil{
                DispatchQueue.main.async {
                    self.remove_load_view(target_view: load_view!)
                }
            }
        }
        
        var is_true_photo:String
        if is_true_photo_switch.isOn{
            is_true_photo = "true"
            userData.is_real_photo = true
        }
        else{
            is_true_photo = "false"
            userData.is_real_photo = false
        }
        
        var send_dic:Dictionary<String,String> = [
            "is_myself": is_true_photo,
            "mode": "change_profile"
            ]
        let child_vc = self.childViewControllers[0] as! SettingProfilePicViewController
        DispatchQueue.global(qos: .default).async {
            if child_vc.profilePicImg.image != userData.img && userData.img != nil{
                var send_img_str = ""
                var init_qulity = 200
                let new_img = child_vc.profilePicImg.image
                while send_img_str.characters.count > 100000 || send_img_str.characters.count == 0{
                    let re_img  = self.resizeImage1(image: new_img!, newWidth: CGFloat(init_qulity))
                    child_vc.profilePicImg.image = re_img
                    let new_img_base64 = imageToBase64(image: re_img, optional: "none")
                    send_img_str = new_img_base64
                    init_qulity -= 1
                }
                
                send_dic["is_new_img"] = "data3image/jpeg3base64," + send_img_str
                // ;會造成字典解析錯誤 詳見 HttpRequestCenter().change_profile
                
            }
            if self.name_text.text != userData.name && userData.name != nil && self.name_text.text != ""{
                send_dic["new_name"] = self.name_text.text!
            }
            
            HttpRequestCenter().change_profile(send_dic: send_dic as NSDictionary) { (return_dic) in
                //["old_user_name": , "show_my_gender": 1, "old_user_pic": member/154/tes_gkpZIVk.jpeg, "show_my_photo": 0, "msg_type": update_user_profile, "user_pic": member/154/tes_gkpZIVk.jpeg, "user_name": ]
                userData.name = return_dic["user_name"] as! String?
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    let url = locale_host + "media/" + (return_dic["user_pic"] as! String)
                    HttpRequestCenter().getHttpImg(url, getImg: { (return_img) in
                        userData.img = return_img
                    })
                    DispatchQueue.main.async {
                        load_view!.removeFromSuperview()
                    }
                    
                }
                
            }
        }
        
    }
    func jump_to_prev_view(){
        let nav = self.parent as? UINavigationController
        if nav != nil{
            nav!.popToRootViewController(animated: true)
        }
    }
    func add_loading_view() -> UIView?{
        let nav = self.parent?.parent as? UITabBarController
        if nav != nil{
            let height = CGFloat(0 + (nav?.view.frame.height)!)
            let load_view = UIView()
            load_view.frame = CGRect(x:0, y: 0, width: self.view.frame.width, height: height)
            load_view.backgroundColor = UIColor.gray
            //self.view.addSubview(load_view)
            let load_simbol = UIActivityIndicatorView()
            load_simbol.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            load_simbol.activityIndicatorViewStyle = .whiteLarge
            load_view.alpha = 0.7
            nav!.view.addSubview(load_view)
            load_simbol.center = CGPoint(x: self.view.frame.width/2, y: height/2)
            load_view.addSubview(load_simbol)
            load_simbol.startAnimating()
            return load_view
        }
        return nil
    }
    func remove_load_view(target_view:UIView){
        target_view.removeFromSuperview()
    }
    
    // override
    override func viewDidLoad() {
        super.viewDidLoad()
        pencilIcon.image = UIImage(named:"pencil")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        pencilIcon.tintColor = UIColor.orange
        pencilIcon.layer.shadowColor = UIColor.black.cgColor
        pencilIcon.layer.shadowOffset = CGSize(width:2,height:2)
        // switch 原本大小是51x31 會往右下縮小
        isTruePhotoSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        // 調整勾勾圖示的預設渲染模式
        isTruePhoto.image = UIImage(named:"True_photo")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        name_text.isHidden  = true
        name_text.delegate = self
        name_btn_obj.setTitle(userData.name!, for: UIControlState.normal)
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
        
        find_user_kb_height()
    }
    
    // delegate -> textFiled
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        name_text.resignFirstResponder()
        
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}









