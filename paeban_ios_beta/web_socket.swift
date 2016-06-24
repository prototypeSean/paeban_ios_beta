//
//  web_socket.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/4/11.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import Starscream


func ws_connected(ws:WebSocket){
    let online_msg = json_dumps(["msg_type":"online"])
    ws.writeData(online_msg)
}

func ws_stay_connect(ws:WebSocket) {
    let online_msg = json_dumps(["msg_type":"test"])
    ws.writeData(online_msg)
}


func ws_onmsg(text:String)-> Dictionary<String,AnyObject>{
    //print(text)
    let unzip_data :NSDictionary = json_load(text)
    //print(unzip_data)
    let unzip_data_output:Dictionary = unzip_data as! Dictionary<String,AnyObject>
    return unzip_data_output
    
}


func ws_connect_fun(ws:WebSocket){
    ws.onConnect = {
        //print("ccccccc")
    }
    ws.connect()
}

public protocol webSocketActiveCenterDelegate{
    func wsOnMsg(msg:Dictionary<String,AnyObject>)
}

public class webSocketActiveCenter{
    
    var wsActiveDelegateForTopicView:webSocketActiveCenterDelegate?
    let wsActiveDelegateForTopicViewWorkList = ["off_line","new_member"]
    
    func wsOnMsg(msg:Dictionary<String,AnyObject>){
        if let msgtype = msg["msg_type"]{
            print(msgtype)
            
            if wsActiveDelegateForTopicViewWorkList.indexOf(msgtype as! String) != nil {
                wsActiveDelegateForTopicView?.wsOnMsg(msg)
            }
        }
    }
}

