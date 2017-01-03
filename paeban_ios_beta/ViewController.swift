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
public var ssss:String?
public var socket:WebSocket!
public var firstConnect = true  //紀錄是否為登入後第一次連接websocket
public var firstActiveApp = true
public var logInState = true    //記錄現在是否為登入狀態
public var wsActive = webSocketActiveCenter() //websocket 資料接收中心
public var cookie:String?       //全域紀錄的餅乾
public var notificationSegueInf:Dictionary<String,String> = [:]
public var socketState = false  //socket是否連線中
public struct setUserData{
    var id:String?
    var name:String?
    var img:UIImage?
    var deviceToken:String?
}   //用戶個人資料
public var userData = setUserData()
public var recive_apns_switch = true
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
public let notificationDelegateCenter_obj = NotificationDelegateCenter()
public let locale_host = "https://www.paeban.com/"
public var main_vc:ViewController?
public var open_app_frist = true
public var app_instence:UIApplication?

public class ViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate, login_paeban_delegate{
    
    @IBAction func loninBottom(_ sender: AnyObject) {
        check_online(in: self, with: fbLogIn)
    }
    @IBOutlet weak var loginbottom_outlet: UIButton!
    @IBOutlet weak var fbButtonOutlet: UIButton!
    @IBAction func singIn(_ sender: AnyObject) {
    }
    @IBAction func logIn(_ sender: AnyObject) {
        self.hide_items()
        loginId.resignFirstResponder()
        logInPw.resignFirstResponder()
        check_online(in: self) {
            self.paeban_login_with_IDPW(id:self.loginId.text!,pw:self.logInPw.text!)
            self.logInPw.text = ""
        }
    }
    @IBOutlet weak var singIn_outlet: UIButton!
    @IBOutlet weak var logIn_outlet: UIButton!
    @IBOutlet weak var loginId: UITextField!
    @IBOutlet weak var logInPw: UITextField!
    @IBOutlet weak var shiftView: UIView!
    @IBOutlet weak var fb_logo: UIImageView!
    @IBOutlet weak var tutorial: UIButton!
    
    
    let login_paeban_obj = login_paeban()
    // MARK: override
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 把註冊前的NAV隱藏
        self.navigationController?.isNavigationBarHidden = true
        print("--viewWillAppear--")
        if !firstActiveApp{
            DispatchQueue.main.async {
                self.show_items()
            }
        }
        
        check_online(in: self, with: autoLogin)
    }
    override public func viewDidAppear(_ animated: Bool) {
//        let alert = UIAlertController(title: "123", message: ssss, preferredStyle: UIAlertControllerStyle.alert)
//        self.present(alert, animated: false, completion: nil)
        
    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 註冊頁顯示NAV
        //self.navigationController?.isNavigationBarHidden = false
    }
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sing_in_segue"{
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        //isInternetAvailable
        //self.show_items()
        main_vc = self
        login_paeban_obj.delegate = self
        loginId.delegate = self
        logInPw.delegate = self
        find_user_kb_height()
        BtnOutlet()
        //testdata
        //notificationSegueInf = ["type":"priv_msg","user_id":"aaasss","topic_id":"nano"]
        //testdata
        
    }
    
    // MARK: 內部函數
    func autoLogin(){
        if let _ = FBSDKAccessToken.current(){
            paeban_login()
            logInState = true
        }
        else{
            hide_items()
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
        if state == "login_yes"{
            firstActiveApp = false
            logInState = true
            cookie = setcookie
            socket = WebSocket(url: URL(string: "wss://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
            socket.headers["Cookie"] = cookie
            socket.delegate = self
            ws_connect_fun(socket)
        }
        else if state == "login_no"{
            show_items()
            cookie = setcookie
            if open_app_frist{
                open_app_frist = false
                DispatchQueue.main.async {
                    self.seugeToTutorial()
                }
            }
            
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
        hide_items()
        fbLoginManager.logIn(withReadPermissions: ["email"],from: self.parent, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.isCancelled{
                    DispatchQueue.main.async {
                        self.show_items()
                    }
                    
                }
                else{
        
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.paeban_login()
                        //self.getFBUserData()
                        logInState = true
                    }
                    else{
                        DispatchQueue.main.async {
                            self.show_items()
                        }
                    }
                }
                
            }
            else{
                print(error)
                print("FB LogIn Error!")
                DispatchQueue.main.async {
                    self.show_items()
                }
            }
        })
        
    }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.paeban_login()
                }
                else{
                    print(error)
                }
            })
        }
    }
    func paeban_login(){
        hide_items()
        if let fb_session = FBSDKAccessToken.current(){
            login_paeban_obj.fb_ssesion = fb_session.tokenString
            login_paeban_obj.get_cookie()
            print("開始登入")
        }
        else{
            print("還沒登入ＦＢ!!!")
            show_items()
        }
    }
    func get_cookie_login_report(state:String) {
        if state != "login_no"{
            print("登入成功!!!")
            firstActiveApp = false
            cookie = state
            socket = WebSocket(url: URL(string: "wss://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
            socket.headers["Cookie"] = cookie
            socket.delegate = self
            ws_connect_fun(socket)
//            DispatchQueue.main.async {
//                self.show_items()
//            }
        }
        else{
            print("登入失敗!!!")
        }
    }
    func paeban_login_with_IDPW(id:String,pw:String){
        print("開始登入...")
        if id != "" && pw != ""{
            self.hide_items()
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
                    self.show_items()
                }))
                self.present(alert, animated: true, completion: {
                    //code
                })
                //self.show_items()
            }
        }
    }
    func hide_items(){
        self.loginbottom_outlet.isHidden = true
        self.loginId.isHidden = true
        self.logInPw.isHidden = true
        self.logIn_outlet.isHidden = true
        self.singIn_outlet.isHidden  = true
        self.fb_logo.isHidden = true
        self.tutorial.isHidden = true
    }
    func show_items(){
        DispatchQueue.main.async {
            self.loginbottom_outlet.isHidden = false
            self.loginId.isHidden = false
            self.logInPw.isHidden = false
            self.logIn_outlet.isHidden = false
            self.singIn_outlet.isHidden  = false
            self.fb_logo.isHidden = false
            self.tutorial.isHidden = false
        }
    }
    
    
    // MARK: webSocket
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
    public func websocketDidConnect(socket: WebSocket){
        socketState = true
        reConnectCount = 0
        //print(NSDate())
        wsTimer?.invalidate()
        wsTimer = Timer.scheduledTimer(timeInterval: 45, target: self, selector: #selector(ViewController.stayConnect), userInfo: nil, repeats: true)
        if firstConnect && logInState{
            ws_connected(socket)
            print("connected")
            firstConnect = false
            self.performSegue(withIdentifier: "segueToMainUI", sender: self)
            DispatchQueue.global(qos: .background).async {
                while myFriendsList.isEmpty{
                    usleep(100)
                }
                if !notificationSegueInf.isEmpty{
                    DispatchQueue.main.async {
                        notificationDelegateCenter_obj.noti_incoming(segueInf: notificationSegueInf)
                    }
                    
                }
            }
            
        }
        else if logInState{
            print("wsReConnected")
            ws_connected(socket)
            wsActive.wsReConnect()
        }
        
    }
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?){
        socketState = false
        print("disConnect")
        if logInState{
            wsTimer?.invalidate()
            wsTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.reConnect), userInfo: nil, repeats: true)
        }
    }
    public func websocketDidReceiveMessage(socket: WebSocket, text: String){
        //print("msgincome=======")
        let msgPack = wsMsgTextToDic(text)
        wsActive.wsOnMsg(msgPack)
        if let msgtype = msgPack["msg_type"] as? String{
            //code
        }
    }
    private func getViewController(indentifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(indentifier)")
    }
    
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data){
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
    
    func simpoAlert(reason:String){
        let mailAlert = UIAlertController(title: "錯誤", message: reason, preferredStyle: UIAlertControllerStyle.alert)
        mailAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            //code
        }))
        self.present(mailAlert, animated: true, completion: {
            //code
        })
    }
    
    // 如果沒登入導向教學頁面
    func seugeToTutorial(){
        if firstActiveApp{
            self.performSegue(withIdentifier: "segueToTutorial", sender: self)
        }
        firstActiveApp = false
    }
    
}






