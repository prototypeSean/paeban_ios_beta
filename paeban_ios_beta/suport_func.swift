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
                    delegate_s?.new_client_topic_msg!(sender: sender)
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
        send_ignore_list_to_server()
        sql_database.delete_recent_topic(topic_id_in: topic_id_in)
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

func synchronize_friend_table(after:(()->Void)?){
    let send_dic = [
        "inactive_list":sql_database.get_inactive_friend_list() as AnyObject
    ]
    HttpRequestCenter().request_user_data_v2("synchronize_friend_table", send_dic: send_dic) { (return_dic:Dictionary<String, AnyObject>?) in
        if return_dic != nil{
            var complet_list:Array<String> = []
            for return_list_data in return_dic!["return_list"] as! Array<Dictionary<String,AnyObject>>{
                sql_database.insert_friend(input_dic: return_list_data)
                complet_list.append(return_list_data["client_id"] as! String)
            }
            if !(return_dic!["return_list"] as! Array<Dictionary<String,AnyObject>>).isEmpty{
                let delegate_list = [wsActive.wasd_FriendTableViewMedol]
                update_private_mag(delegate_target_list: delegate_list)
            }
            let comlete_delete_list = return_dic!["inactive_list"] as! Array<String>
            sql_database.remove_friend_complete(complete_list: comlete_delete_list)
            if !complet_list.isEmpty{
                HttpRequestCenter().request_user_data_v2("synchronize_friend_table_complete", send_dic: ["complete_list": complet_list as AnyObject], InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                    //pass
                })
            }
            
            after?()
        }
    }
}

func synchronize_tmp_client_Table(after:(()->Void)?){
    
    HttpRequestCenter().request_user_data_v2("synchronize_tmp_client_Table_step_1", send_dic: [:]) { (return_dic:Dictionary<String, AnyObject>?) in
        if return_dic != nil{
            var request_client_id_list:Array<String> = []
            for return_list_data in return_dic!["return_list"] as! Array<Dictionary<String, AnyObject>>{
                let client_id = return_list_data["client_id"] as! String
                let client_name = return_list_data["client_name"] as! String
                sql_database.updata_client_name(client_id_ins: client_id, client_name_ins: client_name)
                request_client_id_list.append(client_id)
            }
            let client_img_level_dic = sql_database.check_client_img_levels(client_id_list: request_client_id_list)
            if !client_img_level_dic.isEmpty{
                HttpRequestCenter().request_user_data_v2("synchronize_tmp_client_Table_step_2", send_dic: ["client_img_level_list":client_img_level_dic as AnyObject], InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                    if return_dic != nil{
                        let return_client_img_level_list = return_dic!["return_client_img_level_list"] as! Array<Dictionary<String, AnyObject>>
//                        return_dic  data type
//                            return_dic = [[
//                            "client_id": "client_id",
//                            "img_name": "img_name",
//                            "img_data":["level": "img_string"]
//                            ]]
                        var update_complete_list:Array<String> = []
                        for client_data in return_client_img_level_list{
                            let client_id = client_data["client_id"] as! String
                            let img_name = client_data["img_name"] as! String
                            let client_img_data = client_data["img_data"]! as! Dictionary<String,String>
                            update_complete_list.append(client_id)
                            sql_database.update_client_img(client_id: client_id, img_name: img_name, img_data_s: client_img_data)
                        }
                        HttpRequestCenter().request_user_data_v2("synchronize_tmp_client_Table_step_3", send_dic: ["update_complete_list":update_complete_list as AnyObject], InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                            //pass
                        })
                        after?()
                    }
                })
            }
            else{
                HttpRequestCenter().request_user_data_v2("synchronize_tmp_client_Table_step_3", send_dic: ["update_complete_list":request_client_id_list as AnyObject], InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                    //pass
                })
            }
        }
    }
}


enum load_data_mode {
    case initial
    case page_up
    case page_down
    case change_read_state
    case new_client_msg
    case change_resend_btn
}

