//
//  PublicObject.swift
//  paeban_ios_beta
//
//  Created by elijah on 2018/3/8.
//  Copyright © 2018年 尚義 高. All rights reserved.
//

import Foundation
import Starscream

public var socket:WebSocket!
public var wsActive = webSocketActiveCenter() //websocket 資料接收中心
public var cookie_new = Cookie_Data() //全域紀錄的餅乾
public var userData = setUserData()
