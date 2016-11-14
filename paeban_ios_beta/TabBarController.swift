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
        notificationDelegateCenter_obj.delegata = self
    }
    func switchToView(segueInf:Dictionary<String,String>){
        if let pageInt = leapToPage(segueInf: segueInf){
            self.selectedIndex = pageInt
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
                //print(getClassName(classFullName: classFullName))
            }
            print("ttttttttttttttttttt")
            print(childView[1].self.childViewControllers)
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









