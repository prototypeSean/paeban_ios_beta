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
        print(segueInf)
        if let pageInt = leapToPage(segueInf: segueInf){
            print("準備跳頁")
            print(pageInt)
            self.selectedIndex = pageInt
            
        }
    }
    
}









