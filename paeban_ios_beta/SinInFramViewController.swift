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
    @IBOutlet weak var submitBtn: UIButton!
    
    // MARK: 送出按鈕按下放開行為＆外觀
    @IBAction func submitBtnDown(_ sender: AnyObject) {
        submitBtn.layer.backgroundColor = UIColor(red:0.93, green:0.49, blue:0.21, alpha:1.0).cgColor
    }

    @IBAction func sentSinginData(_ sender: AnyObject) {
        sentSinginData()
        submitBtn.layer.backgroundColor = UIColor.clear.cgColor
    }
    @IBAction func submitBtnCancel(_ sender: AnyObject) {
        submitBtn.layer.backgroundColor = UIColor.clear.cgColor
    }
    @IBAction func emailTextEditBegin(_ sender: AnyObject) {
        emailText.layer.borderColor = UIColor(red:0.98, green:0.49, blue:0.29, alpha:1.0).cgColor
        emailText.layer.borderWidth = 2
        
    }
    @IBAction func emailTextEditEnd(_ sender: AnyObject) {
        emailText.layer.borderColor = UIColor.lightGray.cgColor
        emailText.layer.borderWidth = 1
    }
    @IBAction func password_1EditBegin(_ sender: AnyObject) {
        passWord_1.layer.borderColor = UIColor(red:0.98, green:0.49, blue:0.29, alpha:1.0).cgColor
        passWord_1.layer.borderWidth = 2
    }
    @IBAction func password_1EditEnd(_ sender: AnyObject) {
        passWord_1.layer.borderColor = UIColor.lightGray.cgColor
        passWord_1.layer.borderWidth = 1
    }
    @IBAction func password_2EditBegin(_ sender: AnyObject) {
        passWord_2.layer.borderColor = UIColor(red:0.98, green:0.49, blue:0.29, alpha:1.0).cgColor
        passWord_2.layer.borderWidth = 2
    }
    @IBAction func password_2EditEnd(_ sender: AnyObject) {
        passWord_2.layer.borderColor = UIColor.lightGray.cgColor
        passWord_2.layer.borderWidth = 1
    }
    @IBAction func selectGenderEditBegin(_ sender: AnyObject) {
        selectGenderText.layer.borderColor = UIColor(red:0.98, green:0.49, blue:0.29, alpha:1.0).cgColor
        selectGenderText.layer.borderWidth = 2
    }
    @IBAction func selectGenderEditEnd(_ sender: AnyObject) {
        selectGenderText.layer.borderColor = UIColor.lightGray.cgColor
        selectGenderText.layer.borderWidth = 1
    }
    @IBAction func firstNameEditBegin(_ sender: AnyObject) {
        firstname.layer.borderColor = UIColor(red:0.98, green:0.49, blue:0.29, alpha:1.0).cgColor
        firstname.layer.borderWidth = 2
    }
    @IBAction func firstNameEditEnd(_ sender: AnyObject) {
        firstname.layer.borderColor = UIColor.lightGray.cgColor
        firstname.layer.borderWidth = 1
    }
    
    //MARK: 所有欄位外觀設定
    func ouletsSetting(){
        // 送出按鈕初始外觀 切記把故事版的Type: Custom
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = UIColor.lightGray.cgColor
        submitBtn.layer.cornerRadius = 3
        submitBtn.setTitleColor(UIColor.white, for: .highlighted)
        
        emailText.layer.borderColor = UIColor.lightGray.cgColor
        emailText.layer.borderWidth = 1
        passWord_1.layer.borderColor = UIColor.lightGray.cgColor
        passWord_1.layer.borderWidth = 1
        passWord_2.layer.borderColor = UIColor.lightGray.cgColor
        passWord_2.layer.borderWidth = 1
        selectGenderText.layer.borderColor = UIColor.lightGray.cgColor
        selectGenderText.layer.borderWidth = 1
        firstname.layer.borderColor = UIColor.lightGray.cgColor
        firstname.layer.borderWidth = 1
        
        
    }
    
    let genderOption = ["","男","女","男同","女同"]
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
        ouletsSetting()
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











