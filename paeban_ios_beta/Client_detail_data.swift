//
//  Client_detail_data.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/5/21.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class Client_detail_data{
    let topic_id:String
    let client_id:String
    var level:Int
    var img:UIImage?
    
    init(topic_id:String, client_id:String) {
        self.topic_id = topic_id
        self.client_id = client_id
        self.level = sql_database.get_level(topic_id_in: topic_id, client_id: client_id)
    }
    func get_client_img(act:@escaping (_ return_img:UIImage?)->Void){
        let new_level = sql_database.get_level(topic_id_in: topic_id, client_id: client_id)
        if level != new_level || true{
            if let client_data = sql_database.tmp_client_search(searchByClientId: client_id, level: new_level){
                // 本地有
                DispatchQueue.main.async {
                    self.level = new_level
                    act(base64ToImage(client_data["img"] as! String))
                }
            }
            else{
                // 本地沒有 從網路要
                let send_dic = [
                    "topic_id":topic_id,
                    "level":String(new_level),
                    "client_id":client_id
                ]
                let client_list_for_request:Array<Dictionary<String,String>> = [send_dic]
                let send_dic2 = [
                    "client_list_for_request":client_list_for_request
                ]
                HttpRequestCenter().request_user_data_v2("request_client_detail", send_dic: send_dic2 as Dictionary<String, AnyObject>, InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                    if return_dic != nil{
                        let return_list = return_dic!["return_list"]! as! Array<Dictionary<String,AnyObject>>
                        for datas in return_list{
                            self.level = new_level
                            sql_database.tmp_client_addNew(input_dic: datas)
                            print("data levle: \(datas["level"])")
                            DispatchQueue.main.async {
                                act(base64ToImage(datas["img"] as! String))
                            }
                        }
                    }
                })
            }
        }
    }
    
    
}











