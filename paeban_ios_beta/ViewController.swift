//
//  ViewController.swift
//  paeban_ios_test_3
//
//  Created by 高義 on 2016/4/11.
//  Copyright © 2016年 高義. All rights reserved.
//

import UIKit
import Starscream
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit

// MARK:公用變數
public var socket:WebSocket!
public var firstConnect = true  //紀錄是否為登入後第一次連接websocket
public var logInState = true    //記錄現在是否為登入狀態
public var wsActive = webSocketActiveCenter() //websocket 資料接收中心
public var cookie:String?       //全域紀錄的餅乾
public struct setUserData{
    var id:String?
    var name:String?
    var img:UIImage?
    var deviceToken:String?
}   //用戶個人資料
public var userData = setUserData()
public var nowTopicCellList:Array<MyTopicStandardType> = [] //話題清單
public func addTopicCellToPublicList(_ input_data:MyTopicStandardType){
    if let _ = nowTopicCellList.index(where: { (target) -> Bool in
        if target.topicId_title == input_data.topicId_title{
            return true
        }
        else{return false}
    }){}
    else{nowTopicCellList.insert(input_data, at: 0)}
}
public var myFriendsList:Array<FriendStanderType> = [] //好友清單
public let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()


class ViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate, login_paeban_delegate{
    
    @IBAction func loninBottom(_ sender: AnyObject) {
        check_online(in: self, with: fbLogIn)
    }
    @IBOutlet weak var fbButtonOutlet: UIButton!
    @IBAction func singIn(_ sender: AnyObject) {
    }
    @IBAction func logIn(_ sender: AnyObject) {
        check_online(in: self) { 
            self.paeban_login_with_IDPW(id:self.loginId.text!,pw:self.logInPw.text!)
            self.logInPw.text = ""
        }
    }
    @IBOutlet weak var loginId: UITextField!
    @IBOutlet weak var logInPw: UITextField!
    @IBOutlet weak var shiftView: UIView!
    
    let login_paeban_obj = login_paeban()
    
    // MARK: override
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 把註冊前的NAV隱藏
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 註冊頁顯示NAV
        //self.navigationController?.isNavigationBarHidden = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sing_in_segue"{
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //isInternetAvailable
        login_paeban_obj.delegate = self
        loginId.delegate = self
        logInPw.delegate = self
        find_user_kb_height()
        BtnOutlet()
        check_online(in: self, with: autoLogin)
        
        
    }
    
    // MARK: 內部函數
    func autoLogin(){
        if let _ = FBSDKAccessToken.current(){
            paeban_login()
            logInState = true
        }
        else{
            login_paeban_obj.get_cookie_csrf()
            
        }
    }
    func find_user_kb_height(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func get_cookie_csrf_report(state:String,setcookie:String){
        print(state)
        print(setcookie)
        if state == "login_yes"{
            logInState = true
            cookie = setcookie
            socket = WebSocket(url: URL(string: "wss://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
            socket.headers["Cookie"] = cookie
            socket.delegate = self
            ws_connect_fun(socket)
        }
        else if state == "login_no"{
            cookie = setcookie
        }
        else{
            print(state)
        }
    }
    func BtnOutlet()  {
        fbButtonOutlet.layer.borderWidth = 1.2
        fbButtonOutlet.layer.cornerRadius = 2
        fbButtonOutlet.layer.borderColor = UIColor(red:0.24, green:0.35, blue:0.61, alpha:1.0).cgColor
        loginId.layer.borderWidth = 1
        loginId.layer.borderColor = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0).cgColor
        logInPw.layer.borderWidth = 1
        logInPw.layer.borderColor = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0).cgColor
    }
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
    func paeban_login(){
        if let fb_session = FBSDKAccessToken.current(){
            login_paeban_obj.fb_ssesion = fb_session.tokenString
            login_paeban_obj.get_cookie()
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
            socket.delegate = self
            ws_connect_fun(socket)
        }
        else{
            print("登入失敗!!!")
        }
    }
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
            cookie = setcookie
            socket = WebSocket(url: URL(string: "wss://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
            socket.headers["Cookie"] = cookie
            socket.delegate = self
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
    
    
    // MARK:webSocket
    var wsTimer:Timer?
    var reConnectCount:Int = 0
    func stayConnect() {
        //print(NSDate())
        ws_stay_connect(socket)
    }
    func reConnect(){
        print("reContenting...")
        ws_connect_fun(socket)
        if reConnectCount < 100{
            wsTimer?.invalidate()
        }
    }
    func websocketDidConnect(socket: WebSocket){
        reConnectCount = 0
        //print(NSDate())
        wsTimer?.invalidate()
        wsTimer = Timer.scheduledTimer(timeInterval: 45, target: self, selector: #selector(ViewController.stayConnect), userInfo: nil, repeats: true)
        if firstConnect{
            ws_connected(socket)
            print("connected")
            self.performSegue(withIdentifier: "segueToMainUI", sender: self)
            firstConnect = false
        }
        else{
            print("wsReConnected")
            ws_connected(socket)
            wsActive.wsReConnect()
        }
        
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?){
        print("disConnect")
        if logInState{
            wsTimer?.invalidate()
            wsTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.reConnect), userInfo: nil, repeats: true)
        }
        //print(NSDate())
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String){
        //print("msgincome=======")
        let msgPack = wsMsgTextToDic(text)
        wsActive.wsOnMsg(msgPack)
        if let msgtype = msgPack["msg_type"] as? String{
            if msgtype == "online"{
                //code
            }
        }
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data){
        print("data")
    }
    
    // 監聽鍵盤出現上滑
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                kb_h = keyboardSize.height
                self.view.frame.origin.y -= (keyboardSize.height)
//                print("上高度＝",keyboardSize.height)
//                print("上kb_h=",kb_h)
            }
        }
    }
    
    // 這個變數用來儲存上去時候的鍵盤高度，收起鍵盤時用他，不然會亂跳
    var kb_h:CGFloat = 0.0
    
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += kb_h
//                print("下高度＝",keyboardSize.height)
//                print("下kb_h=",kb_h)
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

}





