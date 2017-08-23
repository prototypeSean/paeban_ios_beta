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
    
    @IBAction func openFB(_ sender: UIBarButtonItem) {
        UIApplication.shared.openURL(URL(string: "https://www.facebook.com/meetgently/")!)
    }
//    @IBAction func openFB(_ sender: UIButton) {
//        UIApplication.shared.openURL(URL(string: "https://www.facebook.com/meetgently/")!)
//    }
//    @IBOutlet weak var openFBOutlet: UIButton!
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
//        if sender.text != nil{
//            change_name_btn_text(text: sender.text!)
//        }
    }
    @IBOutlet weak var name_text: UITextField!
//    @IBAction func name_btn(_ sender: AnyObject) {
//        edit_name()
//    }
//    @IBOutlet weak var name_btn_obj: UIButton!
    

    @IBOutlet weak var is_true_photo_switch: UISwitch!
    @IBAction func save_btn(_ sender: AnyObject) {
        save_data_to_server()
    }
    
    @IBOutlet weak var cmd_line: UITextField!
    @IBAction func reset_act(_ sender: Any) {
        let cmd = cmd_line.text!
        let send_dic = [
            "msg_type":"cmd",
            "text":cmd
        ]
        socket.write(data: json_dumps(send_dic as NSDictionary))
        
    }
    
    @IBOutlet weak var local_cmd_line: UITextField!
    
    @IBAction func local_cmd(_ sender: Any) {
        let cmd_line = local_cmd_line.text!
        if cmd_line  == "recent_db"{
            sql_database.print_recent_db()
        }
        else if cmd_line == "print_block"{
            sql_database.print_block()
        }
        else if cmd_line == "reset_db"{
            sql_database.remove_all_table()
            sql_database.establish_all_table(version: version)
            update_database(reset_db: "1")
        }
        else if cmd_line == "print_ig"{
            sql_database.print_ig()
        }
        else if cmd_line == "print_fl"{
            sql_database.print_fl()
        }
        else if cmd_line == "test_del"{
            sql_database.test_del()
        }
        else if cmd_line == "print_log"{
            sql_database.print_log()
        }
        else if cmd_line == "print_prmsg"{
            sql_database.print_all2()
        }
        else if cmd_line == "print_msg"{
            sql_database.print_all()
        }
        else if cmd_line == "chse"{
            sql_database.change_send_state()
        }
        else if cmd_line == "printtemp"{
            sql_database.print_temp()
        }
        else if cmd_line == "resettmp"{
            sql_database.reset_tmp()
        }
        else if cmd_line == "help"{
            let help_list = [
                "recent_db       列印recent_topic",
                "print_block     列印封鎖清單",
                "reset_db        重置資料庫",
                "print_ig        列印ignore list",
                "print_fl        print friend list",
                "print_prmsg     列印好友對話紀錄",
                "print_msg       列印topicContent",
                "print_log       列印log紀錄"
            ]
            print("----cmd line----")
            for cmd_lines in help_list{
                print(cmd_lines)
            }
        }
        else{
            print("cmd:'\(cmd_line)' 不存在")
        }
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
            let delta_x = ((name_text!.center.y)) - Center_1
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
            isTruePhoto.tintColor = UIColor(red:0.00, green:0.73, blue:0.62, alpha:1.0)
        }
        else{
            isTruePhotoSwitch.isOn = false
            isTruePhoto.tintColor = UIColor.clear
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
        //name_btn_obj.setTitle(text, for: UIControlState.normal)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { 
            self.remove_load_view(target_view: load_view!)
        }
        
        var is_true_photo:String
        if is_true_photo_switch.isOn{
            is_true_photo = "true"
        }
        else{
            is_true_photo = "false"
        }
        
        var send_dic:Dictionary<String,String> = [
            "is_myself": is_true_photo,
            "mode": "change_profile"
            ]
        let child_vc = self.childViewControllers[0] as! SettingProfilePicViewController
        DispatchQueue.global(qos: .default).async {
            var img_str_save:String?
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
                img_str_save = "data3image/jpeg3base64," + send_img_str
                // ;會造成字典解析錯誤 詳見 HttpRequestCenter().change_profile
            }
            if self.name_text.text != userData.name && userData.name != nil && self.name_text.text != ""{
                send_dic["new_name"] = self.name_text.text!
            }
            print("dkdkdk")
            print(send_dic["is_myself"])
            HttpRequestCenter().change_profile(send_dic: send_dic as NSDictionary) { (return_dic) in
                //回復格式
                //["old_user_name": , "show_my_gender": 1, "old_user_pic": member/154/tes_gkpZIVk.jpeg, "show_my_photo": 0, "msg_type": update_user_profile, "user_pic": member/154/tes_gkpZIVk.jpeg, "user_name": ]
                if !return_dic.isEmpty{
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                        //let url = local_host + "media/" + (return_dic["user_pic"] as! String)
                        userData.name = return_dic["user_name"] as! String?
                        let img_name = return_dic["user_pic"] as! String
                        let is_real_pic = return_dic["show_my_photo"] as! Bool
                        let user_name = return_dic["user_name"] as! String
                        if img_str_save != nil{
                            userData.img = base64ToImage(img_str_save!)
                            let input_dic = [
                                "img_name": img_name,
                                "img": img_str_save,
                            ]
                            sql_database.update_user_img(input_dic: input_dic as Dictionary<String, AnyObject>)
                        }
                        userData.is_real_photo = is_real_pic
                        let input_dic2:Dictionary<String, AnyObject> = [
                            "user_name": user_name as AnyObject
                        ]
                        sql_database.update_user_date(input_dic: input_dic2)
                        
                        
//                        HttpRequestCenter().getHttpImg(url, getImg: { (return_img) in
//                            userData.img = return_img
//                        })
                        DispatchQueue.main.async {
                            load_view!.removeFromSuperview()
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async {
                        load_view!.removeFromSuperview()
                        let alert = UIAlertController(title: "錯誤", message: "發生網路異常，本次變更並未儲存", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
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
        self.title = "設定".localized(withComment: "設定->導覽頁左上角文字")
        pencilIcon.image = UIImage(named:"pencil")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        pencilIcon.tintColor = UIColor.orange
        pencilIcon.layer.shadowColor = UIColor.black.cgColor
        pencilIcon.layer.shadowOffset = CGSize(width:2,height:2)
        // switch 原本大小是51x31 會往右下縮小
        isTruePhotoSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        // 調整勾勾圖示的預設渲染模式
        isTruePhoto.image = UIImage(named:"True_photo")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        //name_text.isHidden  = true
        name_text.delegate = self
        name_text.text = userData.name
        //name_btn_obj.setTitle(userData.name!, for: UIControlState.normal)
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
    
    func update_database(reset_db:String){
        print("===update_database===")
        // reset_db "1" 重置server資料庫  "0" 不重置
        let send_dic:Dictionary<String,String> = [
            "init_sql":reset_db,
            "last_topic_content_id":"0",
            "last_private_id":"0"
        ]
        HttpRequestCenter().request_user_data("update_database", send_dic: send_dic) { (return_dic) in
            DispatchQueue.global(qos: .default).async {
                init_sql = false
                var topic_content_data = return_dic["topic_content_data"] as! Array<Dictionary<String,AnyObject>>
                var private_msg_data = return_dic["private_msg_data"] as! Array<Dictionary<String,AnyObject>>
                let friend_list_data = return_dic["friend_list"] as! Array<Dictionary<String,AnyObject>>
                let black_list_data = return_dic["black_list"] as! Array<String>
                let my_topic_list = return_dic["my_topic_list"] as! Array<Dictionary<String,String>>
                let recent_list = return_dic["recent_list"] as! Array<Dictionary<String,String>>
                var tatle_row_count = 0
                
                tatle_row_count += topic_content_data.count
                tatle_row_count += private_msg_data.count
                tatle_row_count += friend_list_data.count
                tatle_row_count += black_list_data.count
                tatle_row_count += my_topic_list.count
                tatle_row_count += recent_list.count
                var writed_row = 0
                var writed_row_present = 0
                func print_writed_row_present(){
                    let temp_present_double = Double(writed_row) / Double(tatle_row_count)
                    let temp_present = Int(temp_present_double * 100)
                    if temp_present > writed_row_present{
                        writed_row_present = temp_present
                    }
                }
                sql_database.insert_topic_msg_mega_ver(input_list: topic_content_data,persent_report:{() in
                    writed_row += 1
                    print_writed_row_present()
                })
                
                sql_database.insert_private_msg_mega_ver(input_list: private_msg_data, persent_report: {() in
                    writed_row += 1
                    print_writed_row_present()
                })
                for friends in friend_list_data{
                    sql_database.insert_friend(input_dic: friends)
                    writed_row += 1
                    print_writed_row_present()
                }
                for blacks in black_list_data{
                    sql_database.insert_black_list_from_server(username_in: blacks)
                    writed_row += 1
                    print_writed_row_present()
                }
                for my_topic_id_s in my_topic_list{
                    sql_database.insert_my_topic_from_server(topic_id_in: my_topic_id_s["topic_id"]!, topic_title_in: my_topic_id_s["topic_title"]!)
                    writed_row += 1
                    print_writed_row_present()
                }
                for recent_datas in recent_list{
                    sql_database.insert_recent_topic(input_dic: recent_datas)
                    writed_row += 1
                }
                sql_database.calculate_ignore_list()
                print("更新完成！！！")
            }
        }
    }
}









