//
//  SinInFramViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/10/11.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class SinInFramViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var selectGenderText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passWord_1: UITextField!
    @IBOutlet weak var passWord_2: UITextField!
    @IBOutlet weak var firstname: UITextField!

    @IBAction func sentSinginData(_ sender: AnyObject) {
        sentSinginData()
    }
    
    let genderOption = ["男","女","男同","女同"]
    let patter = "^[a-zA-z]"
    var photoView:SingInViewController?
    
    
    // internal func
    func simpoAlert(reason:String){
        let mailAlert = UIAlertController(title: "錯誤", message: reason, preferredStyle: UIAlertControllerStyle.alert)
        mailAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            //code
        }))
        self.present(mailAlert, animated: true, completion: {
            //code
        })
    }
    func checkEmail(mail:String) -> Bool{
        if mail != ""{
            let reg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let result = regMatches(for: reg, in: mail)
            if result.count != 0{
                if result[0] == mail{
                    return true
                }
                else{return false}
            }
            else{return false}
        }
        else{return false}
    }
    func checkPhoto(photoVC:SingInViewController?) -> Bool{
        if photoVC != nil{
            if photoVC!.imageViewTemp != nil{
                if photoVC!.imageViewTemp!.image != nil{
                    return true
                }
                else{return false}
            }
            else{return false}
        }
        else{return false}
    }
    func checkPw(password_1:String, password_2:String) -> Bool {
        if password_1 != "" && password_1.characters.count >= 6{
            if password_1 == password_2{
                return true
            }
            else{return false}
        }
        else{return false}
    }
    func checkGender(gender:String) -> Bool{
        if gender != ""{
            return true
        }
        else{return false}
    }
    func checkFirstName(name:String) -> Bool{
        if firstname.text! != ""{
            if 2 <= name.characters.count && name.characters.count <= 20{
                return true
            }
            else{return false}
        }
        else{return false}
    }
    func checkAll() -> Bool {
        var checkAll = true
        if !checkEmail(mail:emailText.text!){
            checkAll = false
            simpoAlert(reason: "電子信箱未填或格式錯誤")
        }
        else if !checkPhoto(photoVC:photoView){
            checkAll = false
            simpoAlert(reason: "尚未選擇圖像")
        }
        else if !checkPw(password_1: passWord_1.text!, password_2: passWord_2.text!){
            checkAll = false
            simpoAlert(reason: "請輸入６個字元以上密碼兩次")
        }
        else if !checkGender(gender: selectGenderText.text!){
            checkAll = false
            simpoAlert(reason: "性別未填")
        }
        else if !checkFirstName(name: firstname.text!){
            checkAll = false
            simpoAlert(reason: "暱稱未填或不符合限制")
        }
        return checkAll
    }
    func sentSinginData(){
//        emailText.resignFirstResponder()
//        passWord_1.resignFirstResponder()
//        passWord_2.resignFirstResponder()
//        firstname.resignFirstResponder()
        
        if checkAll(){
            let base64String = imageToBase64(image: photoView!.imageViewTemp!.image!, optional: "")
            let sendDic:NSDictionary = [
                "email":emailText.text!,
                "password":passWord_1.text!,
                "first_name":firstname.text!,
                "sex":selectGenderText.text!,
                "img":base64String
            ]
            
            HttpRequestCenter().sendSingData(send_dic: sendDic, inViewAct: { (returnDic:Dictionary<String, AnyObject>) in
                let result = returnDic["result"] as! String
                DispatchQueue.main.async(execute: {
                    if result == "check_success"{
                        let mailAlert = UIAlertController(title: "成功", message: "已發送註冊信", preferredStyle: UIAlertControllerStyle.alert)
                        mailAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                            self.dismiss(animated: true, completion: {
                                //code
                            })
                            
                        }))
                        self.present(mailAlert, animated: true, completion: {
                            //code
                        })
                    }
                    else{
                        self.simpoAlert(reason: "email已被註冊")
                    }
                })
                
            })
        }
        
        
    }
    
    // override
    override func viewDidLoad() {
        super.viewDidLoad()
        selectGenderText.delegate = self
        emailText.delegate = self
        passWord_1.delegate = self
        passWord_2.delegate = self
        firstname.delegate = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        photoView = segue.destination as? SingInViewController
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // delegate -> UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField.restorationIdentifier == "selectGender"{
            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            selectGenderText.inputView = picker
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    // datasource -> UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return 4
    }

    
    // delegate -> UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return genderOption[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        selectGenderText.text = genderOption[row]
        self.view.endEditing(true)
    }
}











