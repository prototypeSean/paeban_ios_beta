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


public var socket:WebSocket!
public var wsActive = webSocketActiveCenter()
public var cookie:String?
public struct setUserData{
    var id:String?
    var name:String?
    var imgString:String?
}
public var userData = setUserData()

class ViewController: UIViewController,FBSDKLoginButtonDelegate, WebSocketDelegate{
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRectMake(5, self.view.frame.height - 40, self.view.frame.width - 10, 30)
        view.addSubview(loginButton)
        loginButton.delegate = self
        
        paeban_login()
        
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                print("開始登入...")
                paeban_login()
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    func paeban_login(){
        if let fb_session = FBSDKAccessToken.currentAccessToken(){
            let login_obj = login_paeban(fb_ssesion: fb_session.tokenString)
            cookie = login_obj.get_cookie()
            if cookie != "login_no"{
                print("登入成功!!!")
                socket = WebSocket(url: NSURL(string: "ws://www.paeban.com/echo")!, protocols: ["chat", "superchat"])
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
    var wsTimer:NSTimer?
    var reConnectCount:Int = 0
    
    func stayConnect() {
        //print(NSDate())
        ws_stay_connect(socket)
    }
    
    func reConnect(){
        ws_connect_fun(socket)
        if reConnectCount < 100{
            wsTimer?.invalidate()
        }
    }
    
    
    func websocketDidConnect(socket: WebSocket){
        print("connected")
        reConnectCount = 0
        //print(NSDate())
        wsTimer = NSTimer.scheduledTimerWithTimeInterval(45, target: self, selector: #selector(ViewController.stayConnect), userInfo: nil, repeats: true)
        ws_connected(socket)
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?){
        print("disConnect")
        wsTimer?.invalidate()
        wsTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(ViewController.reConnect), userInfo: nil, repeats: true)
        
        //print(NSDate())
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String){
        //print("msgincome=======")
        let msgPack = ws_onmsg(text)
        wsActive.wsOnMsg(msgPack)
        
    }
    func websocketDidReceiveData(socket: WebSocket, data: NSData){
        print("data")
    }

    
}





