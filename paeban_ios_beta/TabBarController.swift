//
//  TabBarController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/11/10.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit


class TabBarController: UITabBarController, NotificationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        if notificationSegueInf != [:]{
            switchToView(segueInf: notificationSegueInf)
        }
        notificationDelegateCenter_obj.delegata = self
        print("===TabBarController")
    }
    func switchToView(segueInf:Dictionary<String,String>){
        print("=====segueInf======")
        print(segueInf)
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
            for class_s in childView{
                
                let classFullName = String(describing: class_s.self)
                if targetClassName == getClassName(classFullName: classFullName){
                    self.selectedIndex = pageInt
                    let target_VC = class_s.self.childViewControllers[0].self
                    switch pageInt {
                    case 1:
                        let target_VC_transform = target_VC as! MyTopicTableViewController
                        
                        
                        target_VC_transform.autoLeap(segeu_data: segueInf)
                    case 2:
                        let target_VC_transform = target_VC as! RecentTableViewController
                        
                        
                        target_VC_transform.autoLeap()
                    case 3:
                        let target_VC_transform = target_VC as! FriendTableViewController
                        
                        target_VC_transform.autoLeap()
                    default:
                        print("targetClassName is nil")
                    }
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
}









