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


public var socket:WebSocket!
public var wsActive = webSocketActiveCenter()


public var cookie:String?
public struct setUserData{
    var id:String?
    var name:String?
    var img:UIImage?
}
public var userData = setUserData()

public var nowTopicCellList:Array<MyTopicStandardType> = []
public func addTopicCellToPublicList(_ input_data:MyTopicStandardType){
    if let _ = nowTopicCellList.index(where: { (target) -> Bool in
        if target.topicId_title == input_data.topicId_title{
            return true
        }
        else{return false}
    }){}
    else{nowTopicCellList.insert(input_data, at: 0)}
}

public var myFriendsList:Array<FriendStanderType> = []




class ViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate{
    var firstConnect = true
    let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    
    
    @IBAction func loninBottom(_ sender: AnyObject) {
        fbLogIn()
    }
    
    @IBAction func singIn(_ sender: AnyObject) {
    }
    
    @IBAction func logIn(_ sender: AnyObject) {
//        loginSvrollView.center = CGPoint(x: loginSvrollView.frame.width/2, y: loginSvrollView.center.y - sender.frame.minY + 50)
    }
    
    @IBOutlet weak var loginId: UITextField!

    @IBOutlet weak var logInPw: UITextField!
    
    @IBOutlet weak var loginSvrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = FBSDKAccessToken.current(){
            paeban_login()
        }
        loginId.delegate = self
        logInPw.delegate = self
    }
    
    func fbLogIn() {
        fbLoginManager.logIn(withReadPermissions: ["email"],from: self.parent, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
            else{
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
            let login_obj = login_paeban(fb_ssesion: fb_session.tokenString)
            cookie = login_obj.get_cookie()
            if cookie != "login_no"{
                print("登入成功!!!")
                socket = WebSocket(url: URL(string: "ws://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
                socket.headers["Cookie"] = cookie
                socket.delegate = self
                ws_connect_fun(socket)
            }
            else{
                print("登入失敗!!!")
            }
            
        }
        else{
            print("還沒登入ＦＢ!!!")
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
        }
        else{
            print("wsReConnected")
            ws_connected(socket)
            wsActive.wsReConnect()
        }
        
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?){
        print("disConnect")
        wsTimer?.invalidate()
        wsTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.reConnect), userInfo: nil, repeats: true)
        
        //print(NSDate())
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String){
        //print("msgincome=======")
        let msgPack = wsMsgTextToDic(text)
        wsActive.wsOnMsg(msgPack)
        if let msgtype = msgPack["msg_type"] as? String{
            if msgtype == "online"{
                firstConnect = false
            }
        }
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data){
        print("data")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        loginSvrollView.center = CGPoint(x:loginSvrollView.bounds.maxX/2,y:loginSvrollView.bounds.maxY/2 - textField.center.y + 200)
        //print(textField.restorationIdentifier)
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
        print(textField.restorationIdentifier)
        return true
    }
}





