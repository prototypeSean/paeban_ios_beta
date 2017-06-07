//
//  suport_func.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/4/13.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation

func update_topic_content_from_server(delegate_target_list:Array<webSocketActiveCenterDelegate?>){
    let last_topic_content_id = sql_database.get_topic_content_last_checked_server_id()
    let send_dic:Dictionary<String,AnyObject> = [
        "last_topic_content_id": last_topic_content_id as AnyObject
    ]
    HttpRequestCenter().request_user_data_v2("update_topic_content_from_server", send_dic: send_dic) { (return_dic:Dictionary<String, AnyObject>?) in
        DispatchQueue.main.async {
            if return_dic != nil{
                let topic_content_data = return_dic!["topic_content_data"] as! Array<Dictionary<String,AnyObject>>
                for topic_content_data_s in topic_content_data{
                    if topic_content_data_s["sender"] as? String == userData.id{
                        sql_database.insert_self_topic_content(input_dic: topic_content_data_s, option: .server)
                    }
                    else{
                        sql_database.insert_client_topic_content_from_server(input_dic: topic_content_data_s, check_state: .checked)
                        
                        
                        for delegate_target in delegate_target_list{
                            if delegate_target?.new_client_topic_msg != nil{
                                delegate_target?.new_client_topic_msg!(sender: (topic_content_data_s["sender"] as? String)!)
                            }
                        }
                        
                        
                    }
                    //sql_database.inser_date_to_topic_content(input_dic: topic_content_data_s)
                }
            }
        }
        
    }
}
func update_private_mag(delegate_target_list:Array<webSocketActiveCenterDelegate?>){
    let last_id_local = sql_database.get_private_msg_last_checked_server_id()
    let send_dic = [
        "last_id_local":last_id_local
    ]
    HttpRequestCenter().request_user_data_v2("update_private_mag", send_dic: send_dic as Dictionary<String, AnyObject>, InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
        if return_dic != nil{
            let private_msg_data = return_dic!["private_msg_data"] as! Array<Dictionary<String,AnyObject>>
            for private_msg_data_s in private_msg_data{
                sql_database.inser_date_to_private_msg(input_dic: private_msg_data_s)
                let sender = private_msg_data_s["sender_id"] as! String
                for delegate_s in delegate_target_list{
                    if delegate_s?.new_client_topic_msg != nil{
                        delegate_s?.new_client_topic_msg!(sender: sender)
                    }
                }
            }
            
            
        }
    })
}

func random_pass(prasent_rate:Int, work:()->Void){
    let rad = arc4random_uniform(100)
    if Int(rad) <= prasent_rate || true{
        work()
    }
    else{
        print("===訊號已被攔截=== 攔截率：\(100 - prasent_rate)%")
    }
}

class Ignore_list_center{
    func add_ignore_list(topic_id_in: String, client_id: String){
        sql_database.add_ignore_list(topic_id_in: topic_id_in, client_id: client_id)
    }
    func send_ignore_list_to_server(){
        let send_list = sql_database.get_un_send_ignore_list()
        if !send_list.isEmpty{
            let send_dic = ["ignore_list": send_list]
            HttpRequestCenter().request_user_data_v2("send_ignore_list", send_dic: send_dic as Dictionary<String, AnyObject>) { (return_dic: Dictionary<String, AnyObject>?) in
                if return_dic != nil{
                    let is_send_list = return_dic!["is_send_list"]
                    sql_database.update_ignore_list_is_send(is_send_list: is_send_list as! Array<String>)
                }
            }
        }
    }
}







