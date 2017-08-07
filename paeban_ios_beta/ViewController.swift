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
import CoreLocation

// init config     --  named by DK
public var my_blur_img_level_dic = [0:17, 1:12, 2:11, 3:10, 4:9, 5:8, 6:7, 7:5, 8:3, 9:0]
public let version = "1.1.4.0"
public let reset_database = false
public let unlock_img_exp = 7
public let local_host = "http://www.paeban.com/"
// init config


// MARK:公用變數
public var ssss:String?
public var back_ground_state = false
public var socket:WebSocket!
public var firstConnect = true  //紀錄是否為登入後第一次連接websocket
public var firstActiveApp = true // MARK:打包前改為 true****************************
public var logInState = true    //記錄現在是否為登入狀態
public var wsActive = webSocketActiveCenter() //websocket 資料接收中心
public var cookie_new = Cookie_Data() //全域紀錄的餅乾
public var notificationSegueInf:Dictionary<String,String> = [:]
public var socketState = false  //socket是否連線中
public struct setUserData{
    var id:String?
    var name:String?
    var img:UIImage?
    var deviceToken:String?
    var is_real_photo:Bool?
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
public var main_vc:ViewController?
public var open_app_frist = true
public var app_instence:UIApplication?
public var sql_database = SQL_center()
public var init_sql = false
public let image_url_host = "http://www.paeban.com/media/"
public class ViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate, login_paeban_delegate{
    
    @IBAction func loninBottom(_ sender: AnyObject) {
        self.hide_items()
        self.state_loging()
        check_online(in: self, with: fbLogIn)
    }
    @IBOutlet weak var loginbottom_outlet: UIButton!
    @IBOutlet weak var fbButtonOutlet: UIButton!
    @IBAction func singIn(_ sender: AnyObject) {
    }
    @IBAction func logIn(_ sender: AnyObject) {
        if self.loginId.text! != "" && self.logInPw.text! != ""{
            self.hide_items()
            set_loading_view_title(title: "登入中")
            loginId.resignFirstResponder()
            logInPw.resignFirstResponder()
            check_online(in: self) {
                self.paeban_login_with_IDPW(id:self.loginId.text!,pw:self.logInPw.text!)
                //self.logInPw.text = ""
            }
        }
    }
    @IBOutlet weak var singIn_outlet: UIButton!
    @IBOutlet weak var logIn_outlet: UIButton!
    @IBOutlet weak var loginId: UITextField!
    @IBOutlet weak var logInPw: UITextField!
    @IBOutlet weak var shiftView: UIView!
    @IBOutlet weak var fb_logo: UIImageView!
    @IBOutlet weak var tutorial: UIButton!
    @IBOutlet weak var state_lable: UILabel!
    
    let login_paeban_obj = login_paeban()
    var state_switch = true
    var cookie_for_ws:String?
    var location_manager:CLLocationManager?
    var loading_view:UIView?
    var loading_title_lable:UILabel?
    var persent_lable:UILabel?
    
    // =====登入程序=====
    func check_data_base(){
        // 驗證userdata
        // 請求版本號
        sql_database.connect_sql()
        let version_in_db = sql_database.load_version()
        
        func check_user_id(input_dic:Dictionary<String, AnyObject>){
            if version_in_db != version ||
                reset_database ||
                input_dic["user_id"] as? String != sql_database.get_user_id(){
                print("資料庫重置")
                
                sql_database.remove_all_table()
                sql_database.establish_all_table(version: version)
                // reset database
                
                sql_database.insert_user_name(input_dic: input_dic)
                // write user data to database
                
                userData.id = input_dic["user_id"] as? String
                userData.name = input_dic["user_name"] as? String
                // set public var
                
                let url = "\(local_host)media/\(input_dic["img_name"] as! String)"
                HttpRequestCenter().getHttpImg(url, getImg: { (img) in
                    userData.img = img
                    let img_string = imageToBase64(image: img, optional: "withHeader")
                    let insert_dic = [
                        "img_name": input_dic["img_name"] as! String,
                        "img":img_string
                    ]
                    sql_database.update_user_img(input_dic: insert_dic as Dictionary<String, AnyObject>)
                })
                // get user img from server
                // and write into database
                
                set_loading_view_title(title: "正在更新資料庫")
                update_database(reset_db: "1")
            }
            else{
                if let user_data_get_from_local_database = sql_database.get_user_data(){
                    userData.id = user_data_get_from_local_database["user_id"]
                    userData.name = user_data_get_from_local_database["user_name"]
                    if user_data_get_from_local_database["img"] == nil{
                        let img_name = user_data_get_from_local_database["img_name"]!
                        let url = "\(local_host)media/\(img_name)"
                        HttpRequestCenter().getHttpImg(url, getImg: { (img) in
                            userData.img = img
                            let img_string = imageToBase64(image: img, optional: "withHeader")
                            let insert_dic = [
                                "img_name": input_dic["img_name"] as! String,
                                "img":img_string
                            ]
                            sql_database.update_user_img(input_dic: insert_dic as Dictionary<String, AnyObject>)
                        })
                    }
                    else{
                        let img_str = user_data_get_from_local_database["img"]!
                        userData.img = base64ToImage(img_str)
                    }
                }
                else{
                    DispatchQueue.global(qos: .background).async {
                        for _ in 0...10{
                            print("!!!!!!!!嚴重邏輯錯誤 ＃147!!!!!!!!!!")
                            sleep(1)
                            // 無法取得使用者資料！！！
                        }
                    }
                }
                remove_loading_view()
                show_items()
                self.performSegue(withIdentifier: "segueToMainUI", sender: self)
            }
        }
        func get_user_info(){
            HttpRequestCenter().request_user_data_v2("get_user_info", send_dic: [:]) { (rturn_dic:Dictionary<String, AnyObject>?) in
                if rturn_dic != nil{
                    DispatchQueue.main.async {
                        if !check_version(ver_local:version, ver_server: rturn_dic!["version"] as! String){
                            let version_at_least = rturn_dic!["version_at_least"] as! String
                            if !check_version(ver_local:version, ver_server: version_at_least){
                                let alert_msg = String(format: NSLocalizedString("您的版本 %@ 過舊無法服務\n請更新到最新版本 %@", comment: "ViewController"), version, rturn_dic!["version"]! as! String)
                                let alert = UIAlertController(title: "錯誤".localized(withComment: "ViewController"), message: alert_msg, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "確定".localized(withComment: "ViewController"), style: .default, handler: { (act) in
                                    // 聽說ios10以前有問題？
                                    UIApplication.shared.openURL(URL(string: "https://appsto.re/tw/wUz9eb.i")!)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            else{
                                let alert = UIAlertController(title: "通知".localized(withComment: "ViewController"), message:String(format: NSLocalizedString("版本 %@ 已發布\n請盡快更新\n您現在的版本是 %@ ", comment: "ViewController"), rturn_dic!["version"]! as! String, version), preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "更新".localized(withComment: "ViewController"), style: .default, handler: { (act) in
                                    UIApplication.shared.openURL(URL(string: "https://appsto.re/tw/wUz9eb.i")!)
                                }))
                                alert.addAction(UIAlertAction(title: "稍後".localized(withComment: "ViewController"), style: .destructive, handler: { (act) in
                                    check_user_id(input_dic: rturn_dic!)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        else{
                            check_user_id(input_dic: rturn_dic!)
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "錯誤".localized(withComment: "ViewController"), message: "登入失敗，是否重試".localized(withComment: "ViewController"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "是".localized(withComment: "ViewController"), style: .default, handler: { (act) in
                            get_user_info()
                        }))
                        alert.addAction(UIAlertAction(title: "否".localized(withComment: "ViewController"), style: .default, handler: { (act) in
                            HttpRequestCenter().request_user_data("log_out", send_dic: [:]) { (element) in
                                //nil
                            }
                            // 登出
                            cookie_new.reset_cookie()
                            logInState = false
                            firstConnect = true
                            socket.disconnect()
                            let session = URLSession.shared
                            session.finishTasksAndInvalidate()
                            session.reset {
                                //pass
                            }
                            self.remove_loading_view()
                            self.show_items()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        set_loading_view_title(title: "正在確認版本".localized(withComment: "ViewController"))
        get_user_info()
        //===================
//        if version_in_db != version || reset_database{
//        }
        // MARK:"重置資料庫開關"
    }
    // =====登入程序=====
    
    // MARK: override
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 把註冊前的NAV隱藏
        self.navigationController?.isNavigationBarHidden = true
        print("--viewWillAppear--")
        tutorial.titleLabel?.adjustsFontSizeToFitWidth = true
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
        //check_data_base()
        main_vc = self
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
        }
        else{
            hide_items()
            let http_cookies = HTTPCookieStorage.shared
            if let http_cookies_data = http_cookies.cookies(for: URL(string: "\(local_host)")!){
                if !http_cookies_data.isEmpty{
                    if loading_view == nil{
                        set_loading_view_title(title: "正在嘗試自動登入")
                    }
                    login_paeban_obj.get_cookie_csrf()
                }
                else{
                    login_paeban_obj.get_cookie_csrf()
                }
            }
            else{
                login_paeban_obj.get_cookie_csrf()
            }
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
            DispatchQueue.main.async{
                firstActiveApp = false
                logInState = true
                cookie_new.set_cookie(cookie_in: setcookie)
                self.check_data_base()
                self.remove_loading_view()
                socket = WebSocket(url: URL(string: "ws://www.paeban.com/echo/")!, protocols: ["text"])
                socket.headers["Cookie"] = cookie_new.get_cookie()
                socket.delegate = self
                ws_connect_fun(socket)
            }
        }
        else if state == "login_no"{
            DispatchQueue.main.async{
                self.remove_loading_view()
                self.show_items()
                cookie_new.set_cookie_csrf(cookie_in: setcookie)
                if open_app_frist{
                    open_app_frist = false
                    DispatchQueue.main.async {
                        self.seugeToTutorial()
                    }
                }
            }
        }
        else{
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "錯誤".localized(withComment: "ViewController"), message: "網路異常，是否嘗試重新連線".localized(withComment: "ViewController"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "是".localized(withComment: "ViewController"), style: .default, handler: { (act) in
                    self.login_paeban_obj.get_cookie_csrf()
                }))
                alert.addAction(UIAlertAction(title: "否".localized(withComment: "ViewController"), style: .default, handler: { (act) in
                    self.show_items()
                }))
            }
        }
    }
    func BtnOutlet(){
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
            set_loading_view_title(title: "正在使用facebook帳號登入")
//            if loading_view == nil{
//                loading_view = add_loading_view()
//            }
            login_paeban_obj.fb_ssesion = fb_session.tokenString
            login_paeban_obj.login_with_fb()
            print("開始登入")
        }
        else{
            print("還沒登入ＦＢ!!!")
            show_items()
        }
    }
    func login_with_fb_report(state:String) {
        if state == "net_fail"{
            DispatchQueue.main.async {
                self.remove_loading_view()
                let alert = UIAlertController(title: "錯誤".localized(withComment: "ViewController"), message: "網路錯誤，是否嘗試重新登入".localized(withComment: "ViewController"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "是".localized(withComment: "ViewController"), style: .default, handler: { (act) in
                    self.paeban_login()
                }))
                alert.addAction(UIAlertAction(title: "否".localized(withComment: "ViewController"), style: .default, handler: { (act) in
                    self.show_items()
                    self.remove_loading_view()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if state == "login_no"{
            DispatchQueue.main.async{
                self.remove_loading_view()
                self.show_items()
                print("登入失敗!!!")
            }
        }
        else{
            logInState = true
            cookie_new.set_cookie(cookie_in: state)
            check_data_base()
            socket = WebSocket(url: URL(string: "ws://www.paeban.com/echo/")!, protocols: ["text"])
            socket.headers["Cookie"] = cookie_new.get_cookie()
            socket.delegate = self
            ws_connect_fun(socket)
        }
    }
    func paeban_login_with_IDPW(id:String,pw:String){
        print("開始登入...")
        if id != "" && pw != ""{
            self.hide_items()
            login_paeban_obj.get_cookie_by_IDPW(id: id, pw: pw)
        }
        else{
            let alert = UIAlertController(title: "警告".localized(withComment: "ViewController"), message: "帳號或密碼未輸入".localized(withComment: "ViewController"), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title:"確認".localized(withComment: "ViewController"),style: UIAlertActionStyle.default, handler: { (target) in
                //code
            }))
            self.present(alert, animated: true, completion: {
                //code
            })
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func get_cookie_by_IDPW_report(state:String,setcookie:String){
        if state == "timeout"{
            DispatchQueue.main.async {
                self.remove_loading_view()
                print("tout2")
                let alert = UIAlertController(title: "錯誤".localized(withComment: "ViewController"), message: "連線逾時，是否重新連線".localized(withComment: "ViewController"), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "是".localized(withComment: "ViewController"), style: UIAlertActionStyle.default, handler: { (target) in
                    self.hide_items()
                    self.set_loading_view_title(title: "登入中".localized(withComment: "ViewController"))
                    self.loginId.resignFirstResponder()
                    self.logInPw.resignFirstResponder()
                    check_online(in: self) {
                        self.paeban_login_with_IDPW(id:self.loginId.text!,pw:self.logInPw.text!)
                        //self.logInPw.text = ""
                    }
                }))
                alert.addAction(UIAlertAction(title:"否".localized(withComment: "ViewController"),style: UIAlertActionStyle.default, handler: { (target) in
                    //code
                }))
                self.present(alert, animated: true, completion: {
                    //code
                })
            }
        }
        else if state == "login_yes"{
            logInState = true
            cookie_new.set_cookie(cookie_in: setcookie)
            check_data_base()
            socket = WebSocket(url: URL(string: "ws://www.paeban.com/echo/")!, protocols: ["text"])
            socket.headers["Cookie"] = cookie_new.get_cookie()
            socket.delegate = self
            ws_connect_fun(socket)
            
        }
        else if state == "login_no"{
            print("登入失敗")
            DispatchQueue.main.async {
                self.remove_loading_view()
                let alert = UIAlertController(title: "錯誤".localized(withComment: "ViewController"), message: "帳號或密碼錯誤".localized(withComment: "ViewController"), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "確認".localized(withComment: "ViewController"), style: UIAlertActionStyle.default, handler: { (target) in
                    self.logInPw.text = ""
                    self.loginId.becomeFirstResponder()
                    self.show_items()
                    self.remove_loading_view()
                }))
                self.present(alert, animated: true, completion: {
                    //code
                })
                //self.show_items()
            }
        }
        else{
            // net_fail
            DispatchQueue.main.async {
                self.remove_loading_view()
                print("tout1")
                let alert = UIAlertController(title: "錯誤".localized(withComment: "ViewController"), message: "連線逾時，是否重新連線".localized(withComment: "ViewController"), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "是".localized(withComment: "ViewController"), style: UIAlertActionStyle.default, handler: { (target) in
                    self.hide_items()
                    self.set_loading_view_title(title: "登入中")
                    self.loginId.resignFirstResponder()
                    self.logInPw.resignFirstResponder()
                    check_online(in: self) {
                        self.paeban_login_with_IDPW(id:self.loginId.text!,pw:self.logInPw.text!)
                        //self.logInPw.text = ""
                    }
                }))
                alert.addAction(UIAlertAction(title:"否".localized(withComment: "ViewController"),style: UIAlertActionStyle.default, handler: { (target) in
                    //code
                }))
                self.present(alert, animated: true, completion: {
                    //code
                })
            }        }
    }
    func hide_items(){
        DispatchQueue.main.async {
            self.loginbottom_outlet.isHidden = true
            self.loginId.isHidden = true
            self.logInPw.isHidden = true
            self.logIn_outlet.isHidden = true
            self.singIn_outlet.isHidden  = true
            self.fb_logo.isHidden = true
            self.tutorial.isHidden = true
        }
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
    func state_loging(){
//        self.state_lable.text = "登入中"
    }
    func state_init(){
        self.state_lable.text = nil
    }
    func state_download_history_msg(){
        self.state_lable.text = "下載歷史訊息"
    }
    
    // MARK: webSocket
    var wsTimer:Timer?
    var reConnectCount:Int = 0
    func stayConnect() {
        //print(NSDate())
        ws_stay_connect(socket)
    }
    func reConnect(){
        if socket.isConnected{
            socket.disconnect()
        }
        
        print("reConnecting...")
        socket = WebSocket(url: URL(string: "ws://www.paeban.com/echo/")!, protocols: ["text"])
        socket.headers["Cookie"] = cookie_new.get_cookie()
        socket.delegate = self
        ws_connect_fun(socket)
        wsTimer?.invalidate()
    }
    public func websocketDidConnect(socket: WebSocket){
        socketState = true
        reConnectCount = 0
        //print(NSDate())
        wsTimer?.invalidate()
        wsTimer = Timer.scheduledTimer(timeInterval: 45, target: self, selector: #selector(ViewController.stayConnect), userInfo: nil, repeats: true)
        if firstConnect && logInState{
            ws_connected(socket)
            //self.check_sql_state()
            print("connected")
//            socket.write(data: json_dumps([
//                "msg_type": "check_version",
//                "version":version
//            ]))
            firstConnect = false
            firstActiveApp = false
            DispatchQueue.global(qos: .background).async {
                if sql_database.check_database_is_empty(){
                    //self.update_database(reset_db: "1")
                }
                let time_init = Date()
                while myFriendsList.isEmpty{
                    usleep(100)
                    let time_pass = Date().timeIntervalSince(time_init) as Double
                    if time_pass > 5{
                        break
                    }
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
        if logInState && !back_ground_state{
            wsTimer?.invalidate()
            wsTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.reConnect), userInfo: nil, repeats: true)
        }
    }
    public func websocketDidReceiveMessage(socket: WebSocket, text: String){
        let msgPack = wsMsgTextToDic(text)
        wsActive.wsOnMsg(msgPack)
        if let msgtype = msgPack["msg_type"] as? String{
            if msgtype == "update_version"{
                let version_server = msgPack["version"]
                func turn_ver_to_list(ver:String)->Array<Int>{
                    var result_list:Array<Int> = []
                    var temp_chs:String = ""
                    for chs in ver.characters{
                        if chs != "."{
                            temp_chs = "\(temp_chs)\(chs)"
                        }
                        else{
                            result_list.append(Int(temp_chs)!)
                            temp_chs = ""
                        }
                    }
                    if temp_chs != ""{
                        result_list.append(Int(temp_chs)!)
                    }
                    return result_list
                }
                func check_version(ver_local:String,ver_server:String){
                    let ver_local_list = turn_ver_to_list(ver: ver_local)
                    let ver_server_list = turn_ver_to_list(ver: ver_server)
                    let list_len = ver_local_list.count
                    for ver_list_index in 0..<list_len{
                        if ver_server_list[ver_list_index] > ver_local_list[ver_list_index]{
                            let alert = UIAlertController(title: "更新通知".localized(withComment: "ViewController"), message: String(format: NSLocalizedString("版本 %@ 已發布\n請盡快更新\n您現在的版本是 %@ ", comment: "ViewController"), version_server as! String, version), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "確認".localized(withComment: "ViewController"), style: .default, handler: { (action) in
                                //pass
                            }))
                            self.present(alert, animated: true, completion: nil)
                            break
                        }
                    }
                }
                check_version(ver_local:version , ver_server: version_server as! String)
                
            }
            else if msgtype == "announcement"{
                let text = msgPack["announcement"] as! String
                let alert = UIAlertController(title: "公告".localized(withComment: "ViewController"), message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確認".localized(withComment: "ViewController"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
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
        let mailAlert = UIAlertController(title: "錯誤".localized(withComment: "ViewController"), message: reason, preferredStyle: UIAlertControllerStyle.alert)
        mailAlert.addAction(UIAlertAction(title: "確認".localized(withComment: "ViewController"), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
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
    func set_loading_view_title(title:String){
        if loading_view == nil{
            loading_view = add_loading_view()
            loading_title_lable?.text = title
            loading_title_lable?.textColor = UIColor.white
            loading_title_lable?.sizeToFit()
            loading_title_lable?.center = CGPoint(
                x: (loading_view?.frame.width)!/2,
                y: ((loading_view?.frame.height)!/2 + 60)
            )
        }
        else{
            loading_title_lable?.text = title
            loading_title_lable?.sizeToFit()
            loading_title_lable?.center = CGPoint(
                x: (loading_view?.frame.width)!/2,
                y: ((loading_view?.frame.height)!/2 + 60)
            )
        }
    }
    func set_persent_lable(persent:Double){
        if persent_lable != nil{
            persent_lable?.isHidden = false
            persent_lable!.center = CGPoint(
                x: (loading_view?.frame.width)!/2,
                y: ((loading_view?.frame.height)!/2 + 80)
            )
            UIGraphicsBeginImageContext((persent_lable?.frame.size)!)
            let context = UIGraphicsGetCurrentContext()
            context!.setFillColor(UIColor.darkGray.cgColor)
            context!.fill((persent_lable?.frame)!)
            let c1 = UIColor.white.cgColor
            let c2 = UIColor.clear.cgColor
            let left = CGPoint(x: 0, y: (persent_lable?.frame.height)!)
            let right = CGPoint(x: (persent_lable?.frame.width)!, y: (persent_lable?.frame.height)!)
            let colorspace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorspace, colors: [c1, c2] as CFArray, locations: [CGFloat(persent), CGFloat(persent)])
                // change 0.0 above to 1-p if you want the top of the gradient orange
            context!.drawLinearGradient(gradient!, start: left, end: right, options: CGGradientDrawingOptions.drawsAfterEndLocation)
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            persent_lable?.backgroundColor = UIColor(patternImage: img!)
        }
        
    }
    func add_loading_view() -> UIView?{
        print("==add_loading_view")
        let nav = self.parent as? UINavigationController
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
            self.view.addSubview(load_view)
            load_simbol.center = CGPoint(x: self.view.frame.width/2, y: height/2)
            load_view.addSubview(load_simbol)
            load_simbol.startAnimating()
            loading_title_lable = UILabel()
            load_view.addSubview(loading_title_lable!)
            persent_lable = UILabel()
            load_view.addSubview(persent_lable!)
            persent_lable?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.7, height: 5)
            persent_lable?.borderColor = UIColor.white
            persent_lable?.borderWidth = 1
            persent_lable?.cornerRadius = 2.5
            persent_lable?.isHidden = true
            return load_view
        }
        return nil
    }
    func remove_loading_view(){
        self.loading_view?.removeFromSuperview()
        self.loading_view = nil
    }
    func update_database(reset_db:String){
        print("===update_database===")
        // reset_db "1" 重置server資料庫  "0" 不重置
        let send_dic:Dictionary<String,String> = [
            "init_sql":reset_db,
            "last_topic_content_id":"0",
            "last_private_id":"0"
        ]
        HttpRequestCenter().request_user_data_v2("update_database", send_dic: send_dic as Dictionary<String, AnyObject>) { (return_dic) in
            if return_dic != nil{
                DispatchQueue.global(qos: .default).async {
                    init_sql = false
                    var topic_content_data = return_dic?["topic_content_data"] as! Array<Dictionary<String,AnyObject>>
                    var private_msg_data = return_dic?["private_msg_data"] as! Array<Dictionary<String,AnyObject>>
                    let friend_list_data = return_dic?["friend_list"] as! Array<Dictionary<String,AnyObject>>
                    let black_list_data = return_dic?["black_list"] as! Array<String>
                    let my_topic_list = return_dic?["my_topic_list"] as! Array<Dictionary<String,String>>
                    let recent_list = return_dic?["recent_list"] as! Array<Dictionary<String,String>>
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
                            DispatchQueue.main.async {
                                self.set_loading_view_title(title: "正在同步資料庫: \(temp_present)%")
                                self.set_persent_lable(persent: temp_present_double)
                            }
                        }
                    }
                    sql_database.insert_topic_msg_mega_ver(input_list: topic_content_data,persent_report:{() in
                        writed_row += 1
                        print_writed_row_present()
                    })
                    // fly remove =============
                    //                for _ in 0..<50{
                    //                    sql_database.insert_private_msg_mega_ver(input_list: private_msg_data, persent_report: {() in
                    //                        //writed_row += 1
                    //                        //print_writed_row_present()
                    //                    })
                    //                }
                    // ============
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
                    DispatchQueue.main.async {
                        self.remove_loading_view()
                        self.show_items()
                        self.performSegue(withIdentifier: "segueToMainUI", sender: self)
                    }
                }
            }
            else{
                // 重新請求
            }
        }
    }
}






