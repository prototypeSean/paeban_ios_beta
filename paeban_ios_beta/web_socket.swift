//
//  web_socket.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/4/11.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import  Starscream


func ws_connected(_ ws:WebSocket){
    if userData.deviceToken != nil{
        let online_msg = json_dumps(["msg_type":"online","device_token":userData.deviceToken!])
        ws.write(data: online_msg)
    }
    else{
        let online_msg = json_dumps(["msg_type":"online"])
        ws.write(data: online_msg)
    }
}



func ws_stay_connect(_ ws:WebSocket) {
    let online_msg = json_dumps(["msg_type":"test"])
    ws.write(data: online_msg)
}


func wsMsgTextToDic(_ text:String)-> Dictionary<String,AnyObject>{
    //print(text)
    let unzip_data :NSDictionary = json_load(text)
    //print(unzip_data)
    let unzip_data_output:Dictionary = unzip_data as! Dictionary<String,AnyObject>
    return unzip_data_output
    
}


func ws_connect_fun(_ ws:WebSocket){
    ws.connect()
}


@objc public protocol webSocketActiveCenterDelegate{
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>)
    func wsReconnected()
    @objc optional func new_my_topic_msg(sender:String, id_local:String)
    @objc optional func new_client_topic_msg(sender:String)
}

public protocol webSocketActiveCenterDelegate_re{
    func wsReconnected()
}

//MARK:webSocket 資料接收中心
open class webSocketActiveCenter{
    
    let mainWorkList = ["online","off_line","new_member","update_version","topic_msg","priv_msg"]

    var test_List = [""]
    var wsad_ForTopicTableViewController:webSocketActiveCenterDelegate?
    let wsad_ForTopicTableViewControllerList = ["topic_msg","off_line","new_member","topic_closed","search_topic", "friend_confirm"]
    var wasd_ForTopicViewController:webSocketActiveCenterDelegate?
    let wasd_ForTopicViewControllerList = ["topic_msg","topic_closed","has_been_friend","has_been_block","leave_topic_master_client"]
    var wasd_ForChatViewController:webSocketActiveCenterDelegate?
    let wasd_ForChatViewControllerList = ["topic_msg","topic_content_been_read","enter_topic"]
    var wasd_ForMyTopicTableViewController:webSocketActiveCenterDelegate?
    let wasd_ForMyTopicTableViewControllerList = ["topic_msg","new_topic","has_been_friend", "topic_closed","off_line","new_member","friend_confirm","leave_topic_owner","leave_topic_master"]
    var wasd_ForRecentTableViewController:webSocketActiveCenterDelegate?
    let wasd_ForRecentTableViewControllerList = ["topic_msg","off_line","new_member","topic_closed","recentDataCheck","friend_confirm", "leave_topic_client","leave_topic_master_client"]
    var wasd_ForFriendChatViewController:webSocketActiveCenterDelegate?
    let wasd_ForFriendChatViewControllerList = ["history_priv_msg","priv_msg_been_read","priv_msg","has_been_read_many","online"]
    var wasd_ForMyTopicViewController:webSocketActiveCenterDelegate?
    let wasd_ForMyTopicViewControllerList = ["topic_msg","topic_closed","leave_topic_owner"]
    var wasd_FriendTableViewMedol:webSocketActiveCenterDelegate?
    let wasd_FriendTableViewMedol_list = ["check_online","off_line","new_member", "friend_confirm_success", "friend_confirm", "priv_msg"]
    var wasd_ForTabBarController:webSocketActiveCenterDelegate?
    let wasd_ForTabBarController_list = ["topic_msg", "priv_msg"]
    
    
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        if let msgtype = msg["msg_type"]{
            let msgtypeString = msgtype as! String
            print("======\(msgtypeString)=========")
//            if msgtypeString == "has_been_read_mane"{
//                print(msg)
//            }
            
            if mainWorkList.index(of: msgtypeString) != nil {
                if msgtypeString == "online"{
                    //建立個人資料
                    userData.id = msg["user_id"] as? String
                    userData.name = msg["user_name"] as? String
                    userData.is_real_photo = msg["user_is_real_photo"] as? Bool
                    let url = "http://www.paeban.com/media/\(msg["user_pic"] as! String)"
                    HttpRequestCenter().getHttpImg(url){(img:UIImage) -> Void in
                        userData.img = img
                    }
                    //寫入好友清單
//                    let friends_id_list = msg["friends_id_list"] as! Array<String>
//                    let friends_name_list = msg["friends_name_list"] as! Array<String>
//                    let friends_pic_list = msg["friends_pic_list"] as! Array<String>
//                    let friends_sex_list = msg["friends_sex_list"] as! Array<String>
//                    let friends_isme_list = msg["friends_isme_list"] as! Array<Bool>
//                    let friends_online_list = msg["friends_online_list"] as! Array<Bool>
//                    if myFriendsList.isEmpty{
//                        for listIndex in 0 ..< friends_id_list.count{
//                            let insertObj = turnToFriendStanderType(
//                                friends_id_list[listIndex],
//                                name: friends_name_list[listIndex],
//                                sex: friends_sex_list[listIndex],
//                                isRealPhoto: friends_isme_list[listIndex],
//                                online: friends_online_list[listIndex],
//                                photoString: friends_pic_list[listIndex])
//                            myFriendsList.append(insertObj)
//                        }
//                    }
                }
                else if msgtypeString == "topic_msg"{
                    topic_msg_factory(msg: msg)
                }
                else if msgtypeString == "priv_msg"{
                    private_msg_factory(msg: msg)
                }
            }
            
            if wsad_ForTopicTableViewControllerList.index(of: msgtypeString) != nil {
                wsad_ForTopicTableViewController?.wsOnMsg(msg)
            }
            if wasd_ForChatViewControllerList.index(of: msgtypeString) != nil {
                wasd_ForChatViewController?.wsOnMsg(msg)
            }
            if wasd_ForTopicViewControllerList.index(of: msgtypeString) != nil {
                wasd_ForTopicViewController?.wsOnMsg(msg)
            }
            if wasd_ForMyTopicTableViewControllerList.index(of: msgtypeString) != nil {
                wasd_ForMyTopicTableViewController?.wsOnMsg(msg)
            }
            
            if wasd_ForRecentTableViewControllerList.index(of: msgtypeString) != nil {
                wasd_ForRecentTableViewController?.wsOnMsg(msg)
            }
            if wasd_ForFriendChatViewControllerList.index(of: msgtypeString) != nil{
                wasd_ForFriendChatViewController?.wsOnMsg(msg)
            }
            if wasd_ForMyTopicViewControllerList.index(of: msgtypeString) != nil{
                wasd_ForMyTopicViewController?.wsOnMsg(msg)
            }
            if wasd_FriendTableViewMedol_list.index(of: msgtypeString) != nil{
                wasd_FriendTableViewMedol?.wsOnMsg(msg)
            }
            if wasd_ForTabBarController_list.index(of: msgtypeString) != nil{
                wasd_ForTabBarController?.wsOnMsg(msg)
            }
            
            if test_List.index(of: msgtypeString) != nil {
                print("======\(msgtypeString)=========")
                print(msg)
            }
            
            
        }
    }
    
    func wsReConnect(){
        wsad_ForTopicTableViewController?.wsReconnected()
        wasd_ForRecentTableViewController?.wsReconnected()
        wasd_ForMyTopicTableViewController?.wsReconnected()
    }
    // internal func
    func topic_msg_factory(msg:Dictionary<String,AnyObject>){
        let resultDic:Dictionary<String,AnyObject> = msg["result_dic_v2"] as! Dictionary
        if userData.id != nil{
            let sender = resultDic["sender"] as! String
            if sender == userData.id!{
                // 自己說的
                //飛行
                print(resultDic["sender"] as Any)
                DispatchQueue.main.async {
                    sql_database.insert_self_topic_content(input_dic: resultDic, option: .sended)
                    if self.wasd_ForChatViewController?.new_my_topic_msg != nil{
                        // 為了移除送出中的清單
                        self.wasd_ForChatViewController?.new_my_topic_msg!(
                            sender: resultDic["sender"] as! String,
                            id_local: resultDic["id_local"] as! String)
                    }
                    if self.wasd_ForTopicViewController?.new_my_topic_msg != nil{
                        // 為了移除送出中的清單
                        self.wasd_ForTopicViewController?.new_my_topic_msg!(
                            sender: resultDic["sender"] as! String,
                            id_local: resultDic["id_local"] as! String)
                    }
                }
                
               
            }
            else{
                // 別人說的
                let previous_receiver_topic_content_id = msg["previous_receiver_topic_content_id"] as! String
                
                let topic_content_last_checked_server_id = sql_database.get_topic_content_last_checked_server_id()
                print("id_pre_s: \(previous_receiver_topic_content_id) /// id_pre_l: \(topic_content_last_checked_server_id)")
                if Int(previous_receiver_topic_content_id)! >= Int(topic_content_last_checked_server_id)!{
                    sql_database.insert_client_topic_content_from_server(input_dic: resultDic, check_state: .checked)
                    if self.wasd_ForChatViewController?.new_client_topic_msg != nil{
                        self.wasd_ForChatViewController?.new_client_topic_msg!(sender: sender)
                    }
                    if self.wasd_ForMyTopicTableViewController?.new_client_topic_msg != nil{
                        self.wasd_ForMyTopicTableViewController?.new_client_topic_msg!(sender: sender)
                    }
                    if self.wasd_ForTopicViewController?.new_client_topic_msg != nil{
                        self.wasd_ForTopicViewController?.new_client_topic_msg!(sender: sender)
                    }
                    
                }
                else{
                    //跟server要
                    if sql_database.check_database_is_empty(){
                        //updatedatebase
                    }
                    else{
                        update_topic_content_from_server(delegate_target:self.wasd_ForMyTopicTableViewController)
                    }
                    
                }
            }
        }
        //update_recent
    }
    func private_msg_factory(msg:Dictionary<String,AnyObject>){
        let result_dic = msg["result_dic"] as! Dictionary<String,AnyObject>
        let sender = result_dic["sender"] as! String
        if sender == userData.id{
            let id_local = result_dic["id_local"] as! String
            let time_input = result_dic["time"] as! String
            let id_server_input = result_dic["id_server"] as! String
            sql_database.update_private_msg_time(id_local: id_local, time_input: time_input, id_server_input: id_server_input)
        }
        else{
            let private_content_last_id = msg["private_content_last_checked_server_id"] as! String
            let private_content_last_checked_server_id = sql_database.get_private_msg_last_checked_server_id()
            print("ids:\(private_content_last_checked_server_id)  idl:\(private_content_last_id)")
            if Int(private_content_last_checked_server_id)! >= Int(private_content_last_id)!{
                sql_database.inser_date_to_private_msg(input_dic: result_dic)
                if self.wasd_ForFriendChatViewController?.new_client_topic_msg != nil{
                    self.wasd_ForFriendChatViewController?.new_client_topic_msg!(sender: sender)
                }
            }
            else{
                // working
                // update_from_server
            }
        }
        
    }
    
}


// MARK:接收封包資料結構

//=====topic_msg=====
// msg -- msg_type:"topic_msg"
//     -- img:Dtring
//     -- result_dic -- sender:String
//                   -- temp_topic_msg_id
//                   -- topic_content
//                   -- receiver
//                   -- topic_id

//===== =====










