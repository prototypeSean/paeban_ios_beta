//
//  AppDelegate.swift
//  Paeban_iOS_alpha
//
//  Created by 尚義 高 on 2016/5/31.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,UITabBarControllerDelegate{
    var app_event_delegate:app_event?
    var window: UIWindow?
    
    //========deviceToken=======
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        userData.deviceToken = token
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    //========deviceToken=======
    
    //========收到推播=========
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("---didReceiveRemoteNotification---")
        if logInState && (application.applicationState == UIApplicationState.inactive){
            if let segue_inf = userInfo["segue_inf"] as? Dictionary<String,String>{
                notificationSegueInf = segue_inf
            }
        }
    }
    
    //========收到推播=========
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications(application: application)
        // fly
        //=============Launching==============
        app_instence = application
        if ((launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]) != nil){
            let nts = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as! Dictionary<String,AnyObject>
            let segue_inf = nts["segue_inf"] as? Dictionary<String,String>
            if segue_inf != nil{
                notificationSegueInf = segue_inf!
            }
            
        }

        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Override point for customization after application launch.
        
        
        return true
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if (socket != nil){
            socket.disconnect()
        }
        notificationSegueInf = [:]
        socketState = false
        back_ground_state = true
        recive_apns_switch = true
        if tabBar_pointer != nil{
            (tabBar_pointer as! TabBarController).update_badges()
        }
        during_auto_leap = false
        print("====applicationDidEnterBackground======")
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("====applicationDidBecomeActive====")
        app_instence = application
        if !notificationSegueInf.isEmpty && logInState{
            DispatchQueue.global(qos: .userInteractive).async {
                notificationDelegateCenter_obj.noti_incoming(segueInf: notificationSegueInf)
                notificationSegueInf = [:]
            }
            FBSDKAppEvents.activateApp()
            back_ground_state = false
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3, execute: {
                if (socket != nil){
                    if socket.isConnected{
                        socket.disconnect()
                    }
                    else{
                        socket.connect()
                    }
                }
                else{
                    print("socket_is_nil")
                }
                self.app_event_delegate?.app_did_active()
            })
        }
        else{
            FBSDKAppEvents.activateApp()
            back_ground_state = false
            if (socket != nil){
                if socket.isConnected{
                    socket.disconnect()
                }
                else{
                    socket.connect()
                }
            }
            else{
                print("socket_is_nil")
            }
            self.app_event_delegate?.app_did_active()
        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func registerForPushNotifications(application: UIApplication) {
        //let notificationSettings = UIUserNotificationSettings(
            //forTypes: [.Badge, .Sound, .Alert], categories: nil)
        
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
    }
    // MARK:外加函數
    func update_badges(app:UIApplication){
        HttpRequestCenter().request_user_data("get_badges", send_dic: [:]) { (return_dic) in
            if !return_dic.isEmpty{
                DispatchQueue.main.async {
                    let my_topic_badge = return_dic["my_topic_badge"] as? String
                    let recent_badge = return_dic["recent_badge"] as? String
                    let friend_badge = return_dic["friend_badge"] as? String
                    let total_badge = Int(my_topic_badge!)! + Int(recent_badge!)! + Int(friend_badge!)!
                    app.applicationIconBadgeNumber = total_badge
                }
            }
            
        }
    }
    func set_during_auto_leap(){
        during_auto_leap = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { 
            during_auto_leap = false
        }
    }
}

