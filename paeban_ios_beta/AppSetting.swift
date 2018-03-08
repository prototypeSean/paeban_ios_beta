//
//  AppSetting.swift
//  paeban_ios_beta
//
//  Created by elijah on 2018/3/8.
//  Copyright © 2018年 尚義 高. All rights reserved.
//

import Foundation

public let version = "1.9.0.0"
public let reset_database = false // fly default false
public let unlock_img_exp = 7
public let unlock_img_point = 100
public let extra_topic_point = 50
public let unlock_distance_point = 100
public let max_topic_num = 3    // 最大話題並存數

// fly 改port
public let local_host = "http://www.paeban.com:10800/"
public let ws_host = "ws://www.paeban.com:10800/echo/"
public let image_url_host = local_host + "media/"
public var firstActiveApp = true // MARK:打包前改為 true****************************

