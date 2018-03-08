//
//  PublicVariable.swift
//  paeban_ios_beta
//
//  Created by elijah on 2018/3/8.
//  Copyright © 2018年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

public var my_blur_img_level_dic = [0:17, 1:12, 2:11, 3:10, 4:9, 5:8, 6:7, 7:5, 8:3, 9:0]
public let is_VIP = false
public var open_app_frist = true   // default true
public var back_ground_state = false
public var firstConnect = true  //紀錄是否為登入後第一次連接websocket
public var logInState = false    //記錄現在是否為登入狀態
public var notificationSegueInf:Dictionary<String,String> = [:]
public var socketState = false  //socket是否連線中
public struct setUserData{
    var id:String?
    var name:String?
    var img:UIImage?
    var deviceToken:String?
    var is_real_photo:Bool?
}   //用戶個人資料
public var recive_apns_switch = true





