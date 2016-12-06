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
    // internal func
    func logOut(){
        cookie = nil
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
        var is_true_photo:String
        if is_true_photo_switch.isOn{
            is_true_photo = "true"
        }
        else{is_true_photo = "false"}
        
        var send_dic:Dictionary<String,String> = [
            "is_myself": is_true_photo,
            "mode": "change_profile"
            ]
        let child_vc = self.childViewControllers[0] as! SettingProfilePicViewController
        if child_vc.profilePicImg.image != userData.img && userData.img != nil{
            var send_img_str = ""
            var init_qulity = 200
            let new_img = child_vc.profilePicImg.image
            while send_img_str.characters.count > 100000 || send_img_str.characters.count == 0{
                let re_img  = resizeImage1(image: new_img!, newWidth: CGFloat(init_qulity))
                child_vc.profilePicImg.image = re_img
                let new_img_base64 = imageToBase64(image: re_img, optional: "none")
                send_img_str = new_img_base64
                init_qulity -= 1
            }
            
            send_dic["is_new_img"] = "data3image/jpeg3base64," + send_img_str
            // ;會造成字典解析錯誤 詳見 HttpRequestCenter().change_profile
            
        }
        if name_text.text != userData.name && userData.name != nil && name_text.text != ""{
            send_dic["new_name"] = name_text.text!
        }
        
        HttpRequestCenter().change_profile(send_dic: send_dic as NSDictionary) { (return_dic) in
            //["old_user_name": , "show_my_gender": 1, "old_user_pic": member/154/tes_gkpZIVk.jpeg, "show_my_photo": 0, "msg_type": update_user_profile, "user_pic": member/154/tes_gkpZIVk.jpeg, "user_name": ]
            userData.name = return_dic["user_name"] as! String?
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                let url = locale_host + "media/" + (return_dic["user_pic"] as! String)
                HttpRequestCenter().getHttpImg(url, getImg: { (return_img) in
                    userData.img = return_img
                })
            }
            
        }
        let nav = self.parent as? UINavigationController
        if nav != nil{
            nav!.popToRootViewController(animated: true)
        }
        
        
        
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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









