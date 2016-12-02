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
        BtnOutlet()
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
            cookie = state
            socket = WebSocket(url: URL(string: "wss://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
            socket.headers["Cookie"] = cookie
            socket.delegate = main_vc
            ws_connect_fun(socket)
        }
        else{
            print("登入失敗!!!")
        }
    }
    //按鈕外觀設定
    func BtnOutlet()  {
        fbButtonOutlet.layer.borderWidth = 1.2
        fbButtonOutlet.layer.cornerRadius = 2
        fbButtonOutlet.layer.borderColor = UIColor(red:0.24, green:0.35, blue:0.61, alpha:1.0).cgColor
        loginId.layer.borderWidth = 1
        loginId.layer.borderColor = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0).cgColor
        logInPw.layer.borderWidth = 1
        logInPw.layer.borderColor = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0).cgColor
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
