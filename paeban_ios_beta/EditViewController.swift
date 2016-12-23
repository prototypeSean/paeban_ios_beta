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
        clickSubmit()
    }
    @IBOutlet weak var editText: UITextField!
    
    // MARK: override
    override func viewDidLoad() {
        super.viewDidLoad()
        editText.delegate = self
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
    }
    
    
    // MARK: internal func
    func clickSubmit(){
        if 0 < editText.text!.characters.count && editText.text!.characters.count < 100{
            check_if_has_old_topic()
        }
        else{
            editText.text! = ""
            collapseInputBox()
        }
        
    }
    func send_new_topic_msg_to_server(){
        let sendData = json_dumps(["msg_type":"new_topic","text":editText.text!])
        socket.write(data: sendData)
        jump_tp_my_topic()
    }
    
    func check_if_has_old_topic(){
        HttpRequestCenter().get_my_topic_title { (returnData) in
            DispatchQueue.main.async {
                if returnData.isEmpty{
                    self.send_new_topic_msg_to_server()
                    self.editText.text! = ""
                    self.collapseInputBox()
                    self.jump_tp_my_topic()
                }
                else{
                    let alert = UIAlertController(title: "開啟新話題", message: "同時只能有一個話題，確定要開啟新的話題並刪除目前的所有對話？", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (alert_pa) in
                        self.send_new_topic_msg_to_server()
                        self.editText.text! = ""
                        self.collapseInputBox()
                        self.jump_tp_my_topic()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
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







