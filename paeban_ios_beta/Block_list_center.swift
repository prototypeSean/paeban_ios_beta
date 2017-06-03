//
//  Block_list_center.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/5/30.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation

class Block_list_center{
    func add_user_to_block_list(client_id:String){
        sql_database.insert_black_list(username_in: client_id)
        upload_data_to_synchronize_server_block_list()
    }
    func ckeck_user_is_blocked(client_id:String) -> Bool{
        return sql_database.ckeck_user_is_blocked(client_id_in: client_id)
    }
    func upload_data_to_synchronize_server_block_list(){
        let un_send_list = sql_database.get_un_send_block_list()
        if !un_send_list.isEmpty{
            let send_dic = [
                "un_send_list" : un_send_list
            ]
            HttpRequestCenter().request_user_data_v2("upload_block_list", send_dic: send_dic as Dictionary<String, AnyObject>, InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                if return_dic != nil{
                    if let success_list = return_dic!["success_list"] as? Array<String>{
                        sql_database.update_is_send_data(success_list: success_list)
                    }
                }
            })
        }
    }
}






