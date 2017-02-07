//
//  NotificationDelegate.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/11/9.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation

protocol NotificationDelegate {
    func switchToView(segueInf:Dictionary<String,String>)
}

public class NotificationDelegateCenter{
    var delegata:NotificationDelegate?
    
    func noti_incoming(segueInf:Dictionary<String,String>){
        print("NotificationDelegateCenter_noti_incoming")
        delegata?.switchToView(segueInf: segueInf)
    }
}

//notificationDelegateCenter_obj




