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

//MARK:webSocket 資料接收中心
public class webSocketActiveCenter{
    
    let mainWorkList = ["online"]
    
    var test_List = ["remove_old_topics","topic_closed","new_topic"]
    var wsad_ForTopicTableViewController:webSocketActiveCenterDelegate?
    let wsad_ForTopicTableViewControllerList = ["off_line","new_member","topic_closed"]
    var wasd_ForTopicViewController:webSocketActiveCenterDelegate?
    let wasd_ForTopicViewControllerList = ["topic_msg","topic_closed"]
    var wasd_ForChatViewController:webSocketActiveCenterDelegate?
    let wasd_ForChatViewControllerList = ["topic_msg","topic_content_been_read"]
    var wasd_ForMyTopicTableViewController:webSocketActiveCenterDelegate?
    let wasd_ForMyTopicTableViewControllerList = ["topic_msg"]
    
    
    func wsOnMsg(msg:Dictionary<String,AnyObject>){
        if let msgtype = msg["msg_type"]{
            let msgtypeString = msgtype as! String
            //print("======\(msgtypeString)=========")
            
            if mainWorkList.indexOf(msgtypeString) != nil {
                if msgtypeString == "online"{
                    userData.id = msg["user_id"] as? String
                    userData.name = msg["user_name"] as? String
                    userData.imgString  = msg["user_pic"] as? String
                }
            }
            
            if wsad_ForTopicTableViewControllerList.indexOf(msgtypeString) != nil {
                wsad_ForTopicTableViewController?.wsOnMsg(msg)
            }
            if wasd_ForChatViewControllerList.indexOf(msgtypeString) != nil {
                wasd_ForChatViewController?.wsOnMsg(msg)
            }
            if wasd_ForTopicViewControllerList.indexOf(msgtypeString) != nil {
                wasd_ForTopicViewController?.wsOnMsg(msg)
            }
            if wasd_ForMyTopicTableViewControllerList.indexOf(msgtypeString) != nil {
                wasd_ForMyTopicTableViewController?.wsOnMsg(msg)
            }
            
            if test_List.indexOf(msgtypeString) != nil {
                print("======\(msgtypeString)=========")
                print(msg)
//                if msgtypeString == "remove_old_topics"{
//                    let list = msg["old_topic_list"] as! Array<String>
//                    print(list)
//                }
            }
            
        }
    }
}

