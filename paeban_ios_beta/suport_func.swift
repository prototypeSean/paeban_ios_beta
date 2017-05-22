//
//  suport_func.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/4/13.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation

func update_topic_content_from_server(delegate_target:webSocketActiveCenterDelegate?){
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
                        if delegate_target?.new_client_topic_msg != nil{
                            delegate_target?.new_client_topic_msg!(sender: (topic_content_data_s["sender"] as? String)!)
                        }
                        if delegate_target?.new_client_topic_msg != nil{
                            delegate_target?.new_client_topic_msg!(sender: (topic_content_data_s["sender"] as? String)!)
                        }
                    }
                    //sql_database.inser_date_to_topic_content(input_dic: topic_content_data_s)
                }
            }
        }
        
    }
}
func update_private_mag(last_id_local:String, after:(()->Void)?){
    let send_dic = [
        "last_id_local":last_id_local
    ]
    HttpRequestCenter().request_user_data_v2("update_private_mag", send_dic: send_dic as Dictionary<String, AnyObject>, InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
        if return_dic != nil{
            let private_msg_data = return_dic!["private_msg_data"] as! Array<Dictionary<String,AnyObject>>
            for private_msg_data_s in private_msg_data{
                sql_database.inser_date_to_private_msg(input_dic: private_msg_data_s)
            }
            after?()
        }
    })
}

func random_pass(prasent_rate:Int, work:()->Void){
    let rad = arc4random_uniform(100)
    if Int(rad) <= prasent_rate{
        work()
    }
    else{
        print("===訊號已被攔截===")
    }
}









