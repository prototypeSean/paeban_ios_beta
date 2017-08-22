//
//  TabBarController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/11/10.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit


class TabBarController: UITabBarController, NotificationDelegate, webSocketActiveCenterDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
//        if notificationSegueInf != [:]{
//            switchToView(segueInf: notificationSegueInf)
//        }
        tabBar_pointer = self
        wsActive.wasd_ForTabBarController = self
        notificationDelegateCenter_obj.delegata = self
        update_badges()
    }
    func switchToView(segueInf:Dictionary<String,String>){
        // fly
        print("dkdkdk")
        print(Date().timeIntervalSince1970)
        DispatchQueue.main.async {
            if let pageInt = leapToPage(segueInf: segueInf){
                let childView = self.childViewControllers
                var targetClassName:String
                switch pageInt{
                case 1:
                    targetClassName = "MytopicNavViewController"
                case 2:
                    targetClassName = "RecentNavViewController"
                case 3:
                    targetClassName = "FriendNavViewController"
                default:
                    targetClassName = ""
                }
                var target_VC:UIViewController?
                for class_s in childView{
                    let nav = class_s as! UINavigationController
                    nav.popViewController(animated: false)
                    self.selectedIndex = pageInt
                    let classFullName = String(describing: class_s.self)
                    
                    if targetClassName == self.getClassName(classFullName: classFullName){
                        target_VC = class_s.self.childViewControllers[0].self
                    }
                }
                switch pageInt {
                case 1:
                    let target_VC_transform = target_VC as! MyTopicTableViewController
                    //target_VC_transform.pop_to_root_view()
                    //self.selectedIndex = pageInt
                    target_VC_transform.autoLeap(segeu_data: segueInf)
                case 2:
                    let target_VC_transform = target_VC as! RecentTableViewController
                    //target_VC_transform.pop_to_root_view()
                    //self.selectedIndex = pageInt
                    target_VC_transform.autoLeap(segeu_data: segueInf)
                case 3:
                    let target_VC_transform = target_VC as! FriendTableViewController
                    //target_VC_transform.pop_to_root_view()
                    
                    target_VC_transform.autoLeap(segeu_data: segueInf)
                default:
                    print("targetClassName is nil")
                }
            }
        }
    }
    
    
    func getClassName(classFullName:String) -> String{
        var className = ""
        var start_switch = false
        for name_s in classFullName.characters{
            if name_s == "."{
                start_switch = true
            }
            else if name_s == ":"{
                break
            }
            else if start_switch{
                className += String(name_s)
            }
        }
        return className
    }
    func update_badges(){
        let return_dic = sql_database.get_all_badges()
        if return_dic["my_topic_badge"] == "0"{
            self.tabBar.items?[1].badgeValue = nil
        }
        else{
            self.tabBar.items?[1].badgeValue = return_dic["my_topic_badge"]
        }
        
        if return_dic["recent_badge"] == "0"{
            self.tabBar.items?[2].badgeValue = nil
        }
        else{
            self.tabBar.items?[2].badgeValue = return_dic["recent_badge"]
        }
        
        if return_dic["friend_badge"] == "0"{
            self.tabBar.items?[3].badgeValue = nil
        }
        else{
            self.tabBar.items?[3].badgeValue = return_dic["friend_badge"]
        }
        var tatal_badge = 0
        tatal_badge += Int(return_dic["my_topic_badge"]!)!
        tatal_badge += Int(return_dic["recent_badge"]!)!
        tatal_badge += Int(return_dic["friend_badge"]!)!
        // fly unlock
        app_instence?.applicationIconBadgeNumber = tatal_badge
    }
    func wsOnMsg(_ msg: Dictionary<String, AnyObject>) {
        //self.update_badges()
    }
    func wsReconnected(){
        self.update_badges()
    }
    func new_client_topic_msg(sender: String) {
        DispatchQueue.main.async {
            self.update_badges()
        }
    }
}









