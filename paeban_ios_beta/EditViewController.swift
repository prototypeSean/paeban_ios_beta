//
//  EditViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/11/3.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class EditViewController: UIViewController ,UITextFieldDelegate {

    @IBAction func submit(_ sender: AnyObject) {
        clickSubmit(text: editText.text!)
        editText.text = ""
    }
    @IBOutlet weak var editText: UITextField!
    
    // MARK: override
    override func viewDidLoad() {
        super.viewDidLoad()
        editText.delegate = self
    }
    
    
    // MARK: internal func
    func clickSubmit(text:String){
        if check_topic_effective(text:text){
            if 0 < text.characters.count && text.characters.count < 100{
                check_if_has_old_topic_from_local(text:text)
            }
            else{
                editText.text! = ""
                collapseInputBox()
            }
        }
        else{
            let alert = UIAlertController(title: "錯誤", message: "標題不可為空白，或只有hashtag", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func check_topic_effective(text:String) -> Bool{
        if let _ = turn_full_title_to_title(input_full_title: text){
            return true
        }
        return false
    }
    func send_new_topic_msg_to_server_old_ver(){
        let sendData = json_dumps(["msg_type":"new_topic","text":editText.text!])
        socket.write(data: sendData)
        jump_tp_my_topic()
    }
    
    func check_if_has_old_topic_from_server(){
        HttpRequestCenter().get_my_topic_title { (returnData) in
            DispatchQueue.main.async {
                if returnData.isEmpty{
                    self.send_new_topic_msg_to_server_old_ver()
                    self.editText.text! = ""
                    self.collapseInputBox()
                    self.jump_tp_my_topic()
                }
                else{
                    let alert = UIAlertController(title: "開啟新話題", message: "同時只能有一個話題，確定要開啟新的話題並刪除目前的所有對話？", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (alert_pa) in
                        self.send_new_topic_msg_to_server_old_ver()
                        self.editText.text! = ""
                        self.collapseInputBox()
                        self.jump_tp_my_topic()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func check_if_has_old_topic_from_local(text:String){
        let old_topic_count = sql_database.check_old_topic_count()
        if old_topic_count > 0{
            let alert = UIAlertController(title: "開啟新話題", message: "同時只能有一個話題，確定要開啟新的話題並刪除目前的所有對話？", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (alert_pa) in
                self.send_new_topic_to_server(new_topic_title:text)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            send_new_topic_to_server(new_topic_title:text)
        }
    }
    
    func send_new_topic_to_server(new_topic_title:String){
        self.collapseInputBox()
        sql_database.delete_all_my_topic()
        let topic_title_get = turn_full_title_to_title(input_full_title: new_topic_title)!
        let topic_tag_string = turn_full_title_to_tag_save_type(input_full_title: new_topic_title)
        if let id_local = sql_database.insert_my_topic_from_local(topic_title_in:topic_title_get,topic_tag_string_in:topic_tag_string){
            var topic_tag_list:Array<String> = []
            if topic_tag_string != ""{
                topic_tag_list = turn_tag_string_to_tag_list(tag_string: topic_tag_string)
            }
            
            let send_dic:Dictionary<String, AnyObject> = [
                "id_local":id_local as AnyObject,
                "topic_title":topic_title_get as AnyObject,
                "topic_tag_list":topic_tag_list as AnyObject
            ]
            func send(){
                let load_view = add_loading_view()
                HttpRequestCenter().request_user_data_v2("new_topic", send_dic: send_dic, InViewAct: { (return_dic) in
                    DispatchQueue.main.async {
                        if return_dic != nil{
                            sql_database.update_my_topic(local_topic_id_in: return_dic!["id_local"]! as! String, topic_id_in: return_dic!["topic_id"]! as! String)
                            load_view?.removeFromSuperview()
                            self.jump_tp_my_topic()
                        }
                        else{
                            load_view?.removeFromSuperview()
                            let alert = UIAlertController(title: "錯誤", message: "開啟話題失敗，是否重新傳送資料？", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "否", style: .default, handler: { (action) in
                                sql_database.delete_all_my_topic()
                            }))
                            alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (action) in
                                send()
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    }
                    
                })
            }
            send()
        }
        else{
            let alert = UIAlertController(title: "錯誤", message: "資料庫錯誤", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (action) in
                //pass
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func add_loading_view() -> UIView?{
        let nav = self.parent?.parent?.parent as? UITabBarController
        if nav != nil{
            let height = CGFloat(0 + (nav?.view.frame.height)!)
            let load_view = UIView()
            load_view.frame = CGRect(x:0, y: 0, width: self.parent!.view.frame.width, height: height)
            load_view.backgroundColor = UIColor.gray
            //self.view.addSubview(load_view)
            let load_simbol = UIActivityIndicatorView()
            load_simbol.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            load_simbol.activityIndicatorViewStyle = .whiteLarge
            load_view.alpha = 0.7
            nav!.view.addSubview(load_view)
            load_simbol.center = CGPoint(x: self.parent!.view.frame.width/2, y: height/2)
            load_view.addSubview(load_simbol)
            load_simbol.startAnimating()
            return load_view
        }
        return nil
    }
    
    func jump_tp_my_topic(){
        if let tab_bar = self.parent?.parent?.parent as? TabBarController{
            tab_bar.selectedIndex = 1
        }
    }
    
    func collapseInputBox(){
        let parVC = self.parent! as! TopicTableViewController
        parVC.editArea.isHidden = true
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
}







