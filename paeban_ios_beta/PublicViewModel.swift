//
//  PublicViewModel.swift
//  paeban_ios_beta
//
//  Created by elijah on 2018/1/10.
//  Copyright © 2018年 尚義 高. All rights reserved.
//

import Foundation


class PublicViewModel{
    func get_distance(topic_list:Array<MyTopicStandardType>, complete:@escaping (_ new_topic_list:Array<MyTopicStandardType>)->Void){
        var result_topic_list:Array<MyTopicStandardType> = []
        result_topic_list = topic_list
        var client_id_list:Array<String> = []
        for c in result_topic_list{
            if c.dataType != "title" && c.clientId_detial != nil{
                if let _ = client_id_list.index(where: { (ele) -> Bool in
                    if ele == c.clientId_detial{return true}
                    return false
                }){}
                else{
                    client_id_list.append(c.clientId_detial!)
                }
            }
        }
        func replace_distance(c:(key:String,value:Double)){
            if let index_path = result_topic_list.index(where: { (topic:MyTopicStandardType) -> Bool in
                if c.key == topic.clientId_detial{
                    return true
                }
                return false
            }){
                result_topic_list[index_path].distance = String(c.value)
                replace_distance(c: c)
            }
        }
        location_manage.get_distance(client_id_list: client_id_list) { (result_dic:Dictionary<String,Double>) in
            for c in result_dic{
                replace_distance(c: c)
            }
            complete(result_topic_list)
        }
    }
}

















