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
            let sendData = json_dumps(["msg_type":"new_topic","text":editText.text!])
            socket.write(data: sendData)
        }
        else{
            // 輸入有誤
        }
        editText.text! = ""
        collapseInputBox()
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







