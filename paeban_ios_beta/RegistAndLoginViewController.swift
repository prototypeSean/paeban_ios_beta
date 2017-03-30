//
//  RegistAndLoginViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/29.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import Starscream

class RegistAndLoginViewController: UIViewController, login_paeban_delegate {
    @IBAction func fbloninBottom(_ sender: AnyObject) {
        check_online(in: self, with: fbLogIn)
    }
    
    @IBAction func singIn(_ sender: AnyObject) {
    }
    @IBAction func logIn(_ sender: AnyObject) {
        check_online(in: self) {
            self.paeban_login_with_IDPW(id:self.loginId.text!,pw:self.logInPw.text!)
            self.logInPw.text = ""
        }
    }
    @IBOutlet weak var fbButtonOutlet: UIButton!
    @IBOutlet weak var loginId: UITextField!
    @IBOutlet weak var logInPw: UITextField!
    @IBOutlet weak var shiftView: UIView!
    
    let login_paeban_obj = login_paeban()
    
    override func viewDidLoad() {
        login_paeban_obj.delegate = self
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // 以帳號密碼登入
    func paeban_login_with_IDPW(id:String,pw:String){
        print("開始登入...")
        if id != "" && pw != ""{
            login_paeban_obj.get_cookie_by_IDPW(id: id, pw: pw)
        }
        else{
            let alert = UIAlertController(title: "警告", message: "帳號或密碼未輸入", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title:"確認",style: UIAlertActionStyle.default, handler: { (target) in
                //code
            }))
            self.present(alert, animated: true, completion: {
                //code
            })
        }
        
    }
    // 以FB登入
    func fbLogIn() {
        fbLoginManager.logIn(withReadPermissions: ["email"],from: self.parent, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    logInState = true
                }
            }
            else{
                print(error)
                print("FB LogIn Error!")
            }
        })
    }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    print(result)
                    self.paeban_login()
                }
                else{
                    print(error)
                }
            })
        }
    }
    // 登入的驗證程序
    func paeban_login(){
        if let fb_session = FBSDKAccessToken.current(){
            login_paeban_obj.fb_ssesion = fb_session.tokenString
            login_paeban_obj.get_cookie()
            print("開始登入")
        }
        else{
            print("還沒登入ＦＢ!!!")
        }
    }
    func get_cookie_login_report(state:String) {
        if state != "login_no"{
            print("登入成功!!!")
            cookie_new.set_cookie(cookie_in: state)
            socket = WebSocket(url: URL(string: "wss://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
            socket.headers["Cookie"] = cookie_new.get_cookie()
            socket.delegate = main_vc
            ws_connect_fun(socket)
        }
        else{
            print("登入失敗!!!")
        }
    }
    func get_cookie_by_IDPW_report(state:String,setcookie:String){
        if state == "timeout"{
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "錯誤", message: "連線逾時，是否重新連線", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "是", style: UIAlertActionStyle.default, handler: { (target) in
                    self.paeban_login_with_IDPW(id:self.loginId.text!,pw:self.logInPw.text!)
                }))
                alert.addAction(UIAlertAction(title:"否",style: UIAlertActionStyle.default, handler: { (target) in
                    //code
                }))
                self.present(alert, animated: true, completion: {
                    //code
                })
            }
        }
        else if state == "login_yes"{
            logInState = true
            cookie_new.set_cookie(cookie_in: state)
            socket = WebSocket(url: URL(string: "wss://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
            socket.headers["Cookie"] = cookie_new.get_cookie()
            socket.delegate = main_vc
            ws_connect_fun(socket)
        }
        else{
            print("登入失敗")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "錯誤", message: "帳號或密碼錯誤", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.default, handler: { (target) in
                    self.logInPw.text = ""
                    self.loginId.becomeFirstResponder()
                }))
                self.present(alert, animated: true, completion: {
                    //code
                })
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
