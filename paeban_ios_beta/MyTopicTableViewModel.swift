//
//  MyTopicTableViewModel.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/12/13.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

protocol MyTopicTableViewModelDelegate {
    func model_relodata()
    func model_relod_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation)
    func model_delete_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation)
    func model_insert_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation)
    func segue_to_chat_view(detail_cell_obj:MyTopicStandardType)
}

class MyTopicTableViewModel{
    // 主table顯示用清單
    var mytopic:Array<MyTopicStandardType> = []
    var secTopic:Dictionary<String,Array<MyTopicStandardType>> = [:]
    var delegate:MyTopicTableViewModelDelegate?
    var topic_id_wait_to_extend_detail_cell:String?
    var auto_leap_data_dic:Dictionary<String,String> = [:]
    var chat_view:MyTopicViewController?
    var topic_leave_list:Array<Dictionary<String,String>> = []
    
    // ====controller func 2.0 ====
    func main_loading_v2(){
        get_title_cell_from_local_v2()
        get_detail_cell_from_local_v2()
        let need_update_obj_dic = get_client_data_from_temp_client_table()
        get_client_data_from_server(input_dic: need_update_obj_dic)
        reload_all_cell()
        updata_online_state()
        //sql_database.print_all()
    }
    func get_title_cell_from_local_v2(){
        var data_dic:Dictionary<String,AnyObject> = [:]
        let topic_id_list = sql_database.get_my_topics_server_id()
        for topic_id in topic_id_list{
            let temp_dic = sql_database.get_my_topic_detial_for_title_cell(topic_id_in: topic_id)
            data_dic[topic_id] = temp_dic as AnyObject?
        }
        let title_cells = transferToStandardType_title(data_dic)
        remove_expired_cell(title_cells: title_cells)
        for new_cell in title_cells{
            topic_title_cell_add(new_cell: new_cell)
            //self.replace_or_add_title_cell_with_new(new_title_cell: new_cell)
        }
    }
    func remove_expired_cell(title_cells:Array<MyTopicStandardType>){
        var cell_index = 0
        var remove_list:Array<Int> = []
        for cells in mytopic{
            if let _ = title_cells.index(where: { (ele:MyTopicStandardType) -> Bool in
                if cells.topicId_title == ele.topicId_title{
                    return true
                }
                return false
            }){
                //pass
            }
            else{
                remove_list.append(cell_index)
            }
            cell_index += 1
        }
        remove_list = remove_list.sorted().reversed()
        for cell_index in remove_list{
            mytopic.remove(at: cell_index)
        }
    }
    func get_detail_cell_from_local_v2(){
        for cells in mytopic{
            if cells.dataType == "title"{
                if let temp_topic_id = cells.topicId_title{
                    if let basic_cell_list = get_detail_basic_list_from_local_v2(topic_id_in: temp_topic_id, topic_title_in: cells.topicTitle_title!){
                        secTopic[temp_topic_id] = basic_cell_list
                    }
                }
            }
        }
        //get_client_data_from_temp_client_table
        //呼叫get_client_data_from_server
    }
    func get_detail_basic_list_from_local_v2(topic_id_in:String, topic_title_in:String) -> Array<MyTopicStandardType>?{
        // 計算出陽春版資料的子cell
        if let data_dic = sql_database.get_last_line(topic_id_in: topic_id_in){
            // topic_who* -- topic_text
            //               is_read
            var return_list:Array<MyTopicStandardType> = []
            for data_s in data_dic{
                let temp_unit = MyTopicStandardType(dataType: "detail")
                temp_unit.topicId_title = topic_id_in
                temp_unit.clientId_detial = data_s.key
                temp_unit.lastLine_detial = data_s.value["topic_text"] as? String
                temp_unit.read_detial = data_s.value["is_read"] as? Bool
                temp_unit.time = data_s.value["time"] as? Double
                temp_unit.level = data_s.value["level"] as? Int
                temp_unit.topicTitle_title = topic_title_in
                temp_unit.clientOnline_detial = false
                temp_unit.lastSpeaker_id_detial = data_s.value["sender"] as? String
                if temp_unit.lastSpeaker_id_detial == userData.id{
                    temp_unit.lastSpeaker_detial = userData.name
                }
                
                return_list.append(temp_unit)
            }
            if return_list.count >= 2 {
                return_list = return_list.sorted(by: { (el1:MyTopicStandardType, el2:MyTopicStandardType) -> Bool in
                    if el1.time! > el2.time!{
                        return true
                    }
                    return false
                })
            }
            if !return_list.isEmpty{
                return return_list
            }
        }
        return nil
    }
    func get_client_data_from_temp_client_table() -> Dictionary<String,AnyObject>{
        // 將緩衝區資料寫入cell 並返回緩衝區沒有的資料清單
        
        var client_list_for_request:Array<Dictionary<String,String>> = []
        // !!跟server 要詳細資料
        var prepare_check_img_name:Dictionary<String, String> = [:]
        // !!跟server 核對有沒有需要更新照片
        for sec_topic_datas in secTopic.values{
            for cell_s in sec_topic_datas{
                let level = sql_database.get_level(
                    topic_id_in: cell_s.topicId_title!,
                    client_id: cell_s.clientId_detial!)
                if let result_dic = sql_database.tmp_client_search(searchByClientId: cell_s.clientId_detial!, level: level){
                    prepare_check_img_name[cell_s.clientId_detial!] = result_dic["img_name"] as? String
                    update_sec_topic(input_dic: result_dic)
                }
                else{
                    let temp_dic = [
                        "topic_id":cell_s.topicId_title!,
                        "level":String(level),
                        "client_id":cell_s.clientId_detial!
                    ]
                    client_list_for_request.append(temp_dic)
                }
            }
        }
        // MARK:飛行前移除
//        print("跟server要使用者資料")
//        for cxz in client_list_for_request{
//            print(cxz["client_id"])
//        }
        
        return ["client_list_for_request":client_list_for_request as AnyObject,
                "prepare_check_img_name":prepare_check_img_name as AnyObject]
    }
    func update_sec_topic(input_dic:Dictionary<String,AnyObject>){
        let client_id = input_dic["client_id"] as! String
        let level = input_dic["level"] as! Int
        func check_need_update(check_obj:MyTopicStandardType) -> MyTopicStandardType?{
            if check_obj.clientId_detial! == client_id &&
            check_obj.level == level{
                return check_obj
            }
            return nil
        }
        let update_list = secTopic.flatMap{$0.value.flatMap{check_need_update(check_obj:$0)}}
        for update_objs in update_list{
            update_objs.clientName_detial = input_dic["client_name"] as? String
            update_objs.clientPhoto_detial = base64ToImage(input_dic["img"] as! String)
            update_objs.clientSex_detial = input_dic["sex"] as? String
            update_objs.clientIsRealPhoto_detial = input_dic["is_real_pic"] as? Bool
            if update_objs.lastSpeaker_id_detial != userData.id{
                update_objs.lastSpeaker_detial = update_objs.clientName_detial
            }
        }
        
    }
    func get_client_data_from_server(input_dic:Dictionary<String,AnyObject>){
        let client_list_for_request = input_dic["client_list_for_request"] as! Array<Dictionary<String,String>>
        if !client_list_for_request.isEmpty{
            let send_dic1 = ["client_list_for_request":client_list_for_request]
            HttpRequestCenter().request_user_data_v2("request_client_detail", send_dic: send_dic1 as Dictionary<String, AnyObject>, InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                if return_dic != nil{
                    DispatchQueue.main.async {
                        let return_list = return_dic!["return_list"]! as! Array<Dictionary<String,AnyObject>>
                        for datas in return_list{
                            sql_database.tmp_client_addNew(input_dic: datas)
                            self.update_sec_topic(input_dic: datas)
                        }
                        self.reload_all_cell()
                    }
                    
                }
                else{
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3, execute: {
                        self.get_client_data_from_server(input_dic: input_dic)
                    })
                }
            })
        }
    }
    func check_client_online_from_server(user_id_list:Array<String>){
        let send_dic:Dictionary<String,AnyObject> = ["user_id_list":user_id_list as AnyObject]
        HttpRequestCenter().request_user_data_v2("check_client_online", send_dic: send_dic) { (return_dic) in
            if return_dic != nil{
                DispatchQueue.main.async {
                    for client_data in return_dic!{
                        self.update_online_state_in_sec_topic(user_id: client_data.key, online_state: client_data.value as! Bool)
//                        self.update_online_state_in_table_view(user_id: client_data.key, online_state: client_data.value as! Bool)
                        self.reload_all_cell()
                    }
                }
                
            }
        }
    }
    func update_online_state_in_sec_topic(user_id:String, online_state:Bool){
        for topic_datas in secTopic{
            if let index = topic_datas.value.index(where: { (element:MyTopicStandardType) -> Bool in
                if element.clientId_detial == user_id{
                    return true
                }
                return false
            }){
                topic_datas.value[index].clientOnline_detial = online_state
            }
        }
    }
    func update_client_data_from_server(){
    
    }
    func topic_title_cell_add(new_cell:MyTopicStandardType){
        if let _ = mytopic.index(where: { (ele:MyTopicStandardType) -> Bool in
            if ele.topicId_title == new_cell.topicId_title{
                return true
            }
            return false
        }){
            //pass
        }
        else{
            mytopic.append(new_cell)
        }
    }
    func reflash_detail_cell(){
        var remove_list:Array<Int> = []
        var topic_id:String?
        var index_count = 0
        for cells in mytopic{
            if cells.dataType == "detail"{
                topic_id = cells.topicId_title!
                remove_list.append(index_count)
            }
            index_count += 1
        }
        remove_list = remove_list.sorted().reversed()
        for remove_index in remove_list{
            mytopic.remove(at: remove_index)
        }
        if topic_id != nil{
            if let index = mytopic.index(where: { (ele:MyTopicStandardType) -> Bool in
                if ele.topicId_title == topic_id{
                    return true
                }
                return false
            }){
                if secTopic[topic_id!] != nil{
                    secTopic[topic_id!]?.sort(by: { (ele1, ele2) -> Bool in
                        if ele1.time != nil && ele2.time != nil{
                            if ele1.time! < ele2.time!{
                                return true
                            }
                        }
                        return false
                    })
                    for add_cells in secTopic[topic_id!]!{
                        mytopic.insert(add_cells, at: (index + 1))
                    }
                }
            }
        }
    }
    func reload_all_cell(){
        //判斷刷新前狀態
        //刷新後復原狀態
        reflash_detail_cell()
        delegate?.model_relodata()
    }
    func updata_online_state(){
        var client_list:Array<String> = []
        for sec_topic_datas in secTopic.values{
            for client_objs in sec_topic_datas{
                client_list.append(client_objs.clientId_detial!)
            }
        }
        HttpRequestCenter().inquire_online_state(client_id_list: client_list) { (return_dic:Dictionary<String, AnyObject>) in
            if !return_dic.isEmpty{
                DispatchQueue.main.async {
                    let return_dic_copy = return_dic as! Dictionary<String,Bool>
                    for sec_topic_datas in self.secTopic.values{
                        for client_objs in sec_topic_datas{
                            if let online_state = return_dic_copy[client_objs.clientId_detial!]{
                                client_objs.clientOnline_detial = online_state
                            }
                        }
                    }
                    self.reload_all_cell()
                }
            }
        }
    }
    // ====controller func 2.0 ====
    
    
    // ====controller func====
    func main_loading(){
        update_title_cell { (title_cell_list) in
            DispatchQueue.main.async(execute: {
                self.delegate?.model_relodata()
            })
            for title_cell_s in title_cell_list{
                self.update_detail_cell(topic_id: title_cell_s.topicId_title!, aftre_update: { (detail_cell_list) -> Void in
                    if self.topic_id_wait_to_extend_detail_cell == title_cell_s.topicId_title!{
                        self.topic_id_wait_to_extend_detail_cell = nil
                        self.remove_loading_cell()
                        self.remove_detail_cell_from_tableView()
                        self.add_detail_cell_to_tableview(topic_id: title_cell_s.topicId_title!)
                    }
                    self.check_if_need_to_auto_leap()
                })
            }
        }
    }
    func update_title_cell(aftre_update:@escaping(_ title_cell_list:Array<MyTopicStandardType>)->Void){
        get_my_topic_title { (title_cell_list) in
            
            if self.check_title_cell_is_need_update(check_data: title_cell_list){
                for new_title_cell_s in title_cell_list{
                    self.replace_or_add_title_cell_with_new(new_title_cell: new_title_cell_s)
                }
                aftre_update(title_cell_list)
            }
        }
    }
    func update_detail_cell(topic_id:String,aftre_update:@escaping(_ detail_cell_list:Array<MyTopicStandardType>)->Void){
        self.get_my_topic_detail(topic_id, after_get_detail: { (detail_cell_list) in
            if self.check_detail_cell_is_need_update(topic_id: topic_id, check_data: detail_cell_list) || true{
                // 先全通過
                self.secTopic[topic_id] = detail_cell_list
                // MARK: 插入總檢查更新
                if self.check_if_detail_cell_is_extended(topic_id:topic_id){
                    self.remove_detail_cell_from_tableView()
                    self.add_detail_cell_to_tableview(topic_id:topic_id)
                }
                aftre_update(detail_cell_list)
            }
        })
    }
    func update_detail_cell_v2(topic_id:String,aftre_update:@escaping(_ detail_cell_list:Array<MyTopicStandardType>)->Void){
        
    }
    func did_select_row(index:Int){
        auto_leap_data_dic = [:]
        let select_cell = mytopic[index]
        if select_cell.dataType == "title"{
            if self.check_if_detail_cell_is_extended(topic_id:select_cell.topicId_title!){
                // 縮回子cell
                remove_detail_cell_from_tableView()
                remove_loading_cell()
            }
            else{
                // 伸展子cell
                self.remove_detail_cell_from_tableView()
                self.add_detail_cell_to_tableview(topic_id: select_cell.topicId_title!)
//                else{
//                    add_loaging_cell(at: index)
//                    self.topic_id_wait_to_extend_detail_cell = select_cell.topicId_title!
//                    DispatchQueue.global(qos: .background).async {
//                        sleep(5)
//                        if !self.check_detail_cell_has_been_load(topic_id: select_cell.topicId_title!){
//                            print("=======check_detail_cell_has_been_load_nil==========")
//                            self.update_detail_cell(topic_id: select_cell.topicId_title!, aftre_update: { (detail_cell_list) -> Void in
//                                if self.topic_id_wait_to_extend_detail_cell == select_cell.topicId_title!{
//                                    self.topic_id_wait_to_extend_detail_cell = nil
//                                    self.remove_detail_cell_from_tableView()
//                                    self.remove_loading_cell()
//                                    self.add_detail_cell_to_tableview(topic_id: select_cell.topicId_title!)
//                                }
//                            })
//                        }
//                    }
//                }
            }
        }
        else if select_cell.dataType == "detail"{
            self.set_detail_cell_to_read(topic_id: select_cell.topicId_title!, client_id: select_cell.clientId_detial!)
            self.update_title_unread(topic_id: select_cell.topicId_title!)
        }
    }
    func close_topic(index:Int){
        let topic_id = mytopic[index].topicId_title!
        self.remove_list_cell(topic_id: topic_id)
        self.remove_topic_detail_data_from_local(topic_id: topic_id)
        self.sent_close_topic_cmd_to_server(topic_id: topic_id)
        //send mgs to server
    }
    func delete_detail_cell(index:Int){
        let topic_id = mytopic[index].topicId_title!
        let client_id = mytopic[index].clientId_detial!
        self.remove_single_cell(at: index)
        self.remove_singel_detail_data_from_local(topic_id: topic_id, client_id: client_id)
        self.update_title_unread(topic_id: topic_id)
        //send msg to server
    }
    func updataSecTopic_from_socket(_ msg:Dictionary<String,AnyObject>){
        // msg -- msg_type:"topic_msg"
        //     -- img:String
        //     -- result_dic --topic_content_id* -- sender:String
        //                                       -- temp_topic_msg_id
        //                                       -- topic_content
        //                                       -- receiver
        //                                       -- topic_id
        
        let result_dic = msg["result_dic"] as! Dictionary<String,Dictionary<String,String>>
        for topic_content_id in result_dic{
            let topic_content_data = topic_content_id.1
            let topic_id = topic_content_data["topic_id"]!
            if check_if_topic_title_exist(topic_id: topic_id){
                //本地端已有該話題
                let topicWithWho = find_client_id(id_1: topic_content_data["sender"]!, id_2: topic_content_data["receiver"]!)
                if self.check_if_detail_cell_exist(topic_id: topic_id, client_id: topicWithWho){
                    //更新現有資料
                    let localData_index = secTopic[topic_id]!.index(where: { (element) -> Bool in
                        if element.clientId_detial == topicWithWho{
                            return true
                        }
                        return false
                    })
                    let localData = secTopic[topic_id]![localData_index!]
                    if topic_content_data["sender"] == userData.id{
                        localData.lastSpeaker_detial = userData.name
                    }
                    else{
                        localData.lastSpeaker_detial = localData.clientName_detial
                    }
                    localData.lastLine_detial = topic_content_data["topic_content"]
                    if userData.id == topic_content_data["sender"]{
                        localData.read_detial = true
                    }
                    else{
                        localData.read_detial = false
                    }
                    secTopic[topic_id]!.remove(at: localData_index!)
                    secTopic[topic_id]!.insert(localData, at: 0)

                    let uiDataIndex = mytopic.index(where: { (MyTopicStandardType) -> Bool in
                        if MyTopicStandardType.topicId_title == topic_id
                            && MyTopicStandardType.clientId_detial == topicWithWho{
                            return true
                        }
                        else{return false}
                    })
                    if uiDataIndex != nil{
                        mytopic.remove(at: Int(uiDataIndex!))
                        let index_path = IndexPath(row: uiDataIndex!, section: 0)
                        self.delegate?.model_delete_row(index_path_list: [index_path], option: .left)
                        add_new_detail_cell_to_table(detail_cell: localData)
                    }
                    self.update_title_unread(topic_id: localData.topicId_title!)
                    self.delegate?.model_relodata()
                }
                else{
                    //新建資料
                    request_sec_topic_config(topic_id: topic_id, topicWithWho: topicWithWho, topic_content_id: topic_content_id.key, any_func: {(cell_obj) in
                        if topic_content_data["sender"] == userData.id{
                            cell_obj.lastSpeaker_detial = userData.name
                        }
                        else{
                            cell_obj.lastSpeaker_detial = cell_obj.clientName_detial
                        }
                        
                        cell_obj.lastLine_detial = topic_content_data["topic_content"]
                        self.secTopic[topic_id]?.insert(cell_obj, at: 0)
                        
                        DispatchQueue.main.async {
                            self.update_title_unread(topic_id: topic_id)
                            if self.check_if_detail_cell_is_extended(topic_id: topic_id){
                                self.add_new_detail_cell_to_table(detail_cell: cell_obj)
                            }
                            
                        }
                        
                        
                    })
                }
            }
            else{
                self.main_loading()
            }
            
        }
        
    }
    func prepare_auto_leap(topic_id:String, client_id:String){
        
        self.auto_leap_data_dic = [
            "topic_id":topic_id,
            "client_id":client_id
        ]
        self.check_if_need_to_auto_leap()
    }
    func topic_closed(topic_id:String){
        self.remove_list_cell(topic_id: topic_id)
    }
    func socket_client_ON_line_signal(msg:Dictionary<String,AnyObject>) {
        let onLineUser = msg["user_id"] as! String
        if self.check_if_need_update_online_state(client_id: onLineUser, new_online_state: true){
            self.update_online_state_in_sec_topic(client_id: onLineUser, new_online_state: true)
        }
    }
    func socket_client_OFF_line_signal(msg:Dictionary<String,AnyObject>) {
        let offLineUser = msg["user_id"] as! String
        if self.check_if_need_update_online_state(client_id: offLineUser, new_online_state: false){
            self.update_online_state_in_sec_topic(client_id: offLineUser, new_online_state: false)
        }
    }
    func remove_detail_cell(by client_id:String){
        if let index = mytopic.index(where: { (element) -> Bool in
            if element.clientId_detial == client_id{
                return true
            }
            return false
        }){
            remove_single_cell(at: index)
        }
    }
    
    // ======施工中=====
    func add_topic_closed_list(topic_id:String, client_name:String){
        if let topic_index = mytopic.index(where: { (element) -> Bool in
            if element.topicId_title == topic_id{
                return true
            }
            return false
        }){
            if let topic_title = mytopic[topic_index].topicTitle_title{
                self.topic_leave_list.append([
                        "topic_title":topic_title,
                        "client_name":client_name
                    ])
            }
            
        }
    }
    func send_leave_topic_master(){
        let data_list = sql_database.get_leave_topic_master_table_list()
        for send_data in data_list{
            let temp_dic:NSDictionary = [
                "topic_id": send_data["topic_id"]!,
                "client_id": send_data["client_id"]!
            ]
            let temp_dic2:NSDictionary = [
                "msg_type": "leave_topic_master",
                "msg": temp_dic
            ]
            socket.write(data: json_dumps(temp_dic2))
        }
    }
    
    // ======施工中=====
    
    // ====tool func====
        // internet operate
    private func get_my_topic_title(after_get_title_cell:@escaping (_:Array<MyTopicStandardType>)->Void){
        DispatchQueue.global(qos:.background).async{ () -> Void in
            HttpRequestCenter().get_my_topic_title { (returnData) in
                let title_cell_data = self.transferToStandardType_title(returnData)
                after_get_title_cell(title_cell_data)
            }
        }
    }
    private func get_my_topic_detail(_ topicId:String, after_get_detail:@escaping (_ detial_cell_list:Array<MyTopicStandardType>)->Void){
        DispatchQueue.global(qos:.background).async{ () -> Void in
            let httpObj = HttpRequestCenter()
            httpObj.get_my_topic_detail(topicId, InViewAct: { (returnData) in
                DispatchQueue.main.async(execute: {
                    if self.check_detail_return_dic_is_effective(return_dic: returnData){
                        let detial_cell_data = self.transferToStandardType_detail(returnData)
                        after_get_detail(detial_cell_data)
                    }
                    else{
                        self.remove_list_cell(topic_id: topicId)
                    }
                })
            })
        }
    }
    private func request_sec_topic_config(topic_id:String, topicWithWho:String, topic_content_id:String, any_func:@escaping (MyTopicStandardType)->Void){
        
        HttpRequestCenter().request_topic_msg_config(topic_id, client_id: topicWithWho, topic_content_id: topic_content_id, InViewAct: { (return_dic) in
            let detail_cell_obj = MyTopicStandardType(dataType: "detail")
            detail_cell_obj.topicId_title = topic_id
            detail_cell_obj.clientId_detial = topicWithWho
            detail_cell_obj.clientName_detial = return_dic["client_name"] as? String
            detail_cell_obj.topicContentId_detial = return_dic["topic_content_id"] as? String
            let img_string = return_dic["img"] as! String
            detail_cell_obj.clientPhoto_detial = base64ToImage(img_string)
            detail_cell_obj.clientSex_detial = return_dic["client_sex"] as? String
            detail_cell_obj.clientOnline_detial = false
            detail_cell_obj.clientIsRealPhoto_detial = return_dic["client_is_real_photo"] as? Bool
            detail_cell_obj.read_detial = return_dic["read"] as? Bool
            
            any_func(detail_cell_obj)
        })
    }
    private func sent_close_topic_cmd_to_server(topic_id:String){
        let send_dic:NSDictionary = [
            "msg_type": "close_topic",
            "topic_id": topic_id
        ]
        socket.write(data: json_dumps(send_dic))
    }
    
        // ====check func
    private func check_detail_cell_is_need_update(topic_id:String, check_data:Array<MyTopicStandardType>) -> Bool{
        var return_state = false
        if self.secTopic[topic_id] == nil{
            return true
        }
        else{
            for check_data_s in check_data{
                if let cell_index = self.secTopic[topic_id]?.index(where: { (element) -> Bool in
                    if check_data_s.clientId_detial == element.clientId_detial{
                        return_state = true
                    }
                    return false
                }){
                    let old_data = self.secTopic[topic_id]![cell_index]
                    if old_data.lastLine_detial != check_data_s.lastLine_detial{
                        return_state = true
                    }
                    else if old_data.clientOnline_detial != check_data_s.clientOnline_detial{
                        return_state = true
                    }
                }
                else{
                    return_state = true
                }
            }
        }
        return return_state
    }
    private func check_title_cell_is_need_update(check_data:Array<MyTopicStandardType>) -> Bool{
        for check_data_s in check_data{
            if let title_cell_index = mytopic.index(where: { (MyTopicStandardType_parameter) -> Bool in
                if check_data_s.topicId_title == MyTopicStandardType_parameter.topicId_title{
                    return true
                }
                return false
            }){
                if mytopic[title_cell_index].topicWithWhoDic_title! != check_data_s.topicWithWhoDic_title!{
                    return true
                }
            }
            else{
                return true
            }
        }
        return false
    }
    private func check_if_tableView_need_to_update_detail_cell(topic_id:String) -> Bool{
        let local_detail_cell_list = secTopic[topic_id]!
        for local_detail_cell_s in local_detail_cell_list{
            if let _ = mytopic.index(where: { (element) -> Bool in
                if element.dataType == "detail" &&
                    element.topicId_title! == topic_id &&
                    element.clientId_detial == local_detail_cell_s.clientId_detial{
                    return true
                }
                return false
            }){
                //pass
            }
            else{
                return true
            }
        }
        return false
    }
    private func check_detail_cell_has_been_load(topic_id:String) -> Bool{
        if secTopic[topic_id] == nil{
            return false
        }
        else{
            return true
        }
    }
    private func check_if_need_to_auto_leap(){
        if !self.auto_leap_data_dic.isEmpty{
            let topic_id = self.auto_leap_data_dic["topic_id"]!
            let client_id = self.auto_leap_data_dic["client_id"]!
            if secTopic[topic_id] != nil{
                if let detail_obj_index = secTopic[topic_id]!.index(where: { (element) -> Bool in
                    if element.clientId_detial == client_id{
                        return true
                    }
                    return false
                }){
                    self.auto_leap_data_dic = [:]
                    let detail_obj = secTopic[topic_id]![detail_obj_index]
                    delegate?.segue_to_chat_view(detail_cell_obj: detail_obj)
                }
            }
        }
    }
    private func check_if_detail_cell_is_extended(topic_id:String) -> Bool{
        if let list_cell_index = mytopic.index(where: { (element) -> Bool in
            if element.dataType == "title" && element.topicId_title == topic_id{
                return true
            }
            return false
        }){
            if list_cell_index as Int == mytopic.count - 1{
                return false
            }
            else if mytopic[(list_cell_index as Int) + 1].dataType == "title"{
                return false
            }
            return true
        }
        return false
    }
    private func check_if_topic_title_exist(topic_id:String) -> Bool{
        if let _ = mytopic.index(where: { (element) -> Bool in
            if element.dataType == "title" && element.topicId_title == topic_id{
                return true
            }
            return false
        }){
            return true
        }
        return false
    }
    private func check_if_detail_cell_exist(topic_id:String, client_id:String) -> Bool{
        if let localTopicData = secTopic[topic_id]{
            if let _ = localTopicData.index(where: { (MyTopicStandardType) -> Bool in
                if MyTopicStandardType.clientId_detial == client_id{
                    return true
                }
                else{return false}
            }){
                return true
            }
            return false
        }
        return false
        
    }
    private func check_detail_return_dic_is_effective(return_dic:Dictionary<String,AnyObject>)  -> Bool{
        let topic_id = return_dic["topic_id"] as! String
        if topic_id == "none"{
            return false
        }
        return true
    }
    private func check_if_need_update_online_state(client_id:String, new_online_state:Bool) -> Bool{
        for detail_cell_list_s in secTopic.values{
            if let detail_cell_index = detail_cell_list_s.index(where: { (element) -> Bool in
                if element.clientId_detial == client_id{
                    return true
                }
                return false
            }){
                if detail_cell_list_s[detail_cell_index].clientOnline_detial != new_online_state{
                    return true
                }
            }
        }
        return false
    }
    
        // ====data type transfer
    //MARK: 轉換用函數
    private func transferToStandardType_title(_ inputData:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>{
        // return_dic = topic_id* -- topic_title : String
        //                        -- topics               -- topic_with_who_id* -- read:Bool
        //                        -- hash_tag
        var tempMytopicList = [MyTopicStandardType]()
        for topic_id in inputData{
            let topicTitleData = MyTopicStandardType(dataType:"title")
            let topicTitle = (topic_id.1 as! Dictionary<String,AnyObject>)["topic_title"] as! String
            let topicId = topic_id.0
            var topicWithWhoDic: Dictionary<String,Bool> = [:]
            for topic_with_who_id in (topic_id.1 as! Dictionary<String,AnyObject>)["topics"] as! Dictionary<String,AnyObject>{
                let read = (topic_with_who_id.1 as! Dictionary<String,Bool>)["read"]
                topicWithWhoDic[topic_with_who_id.0] = read
            }
            topicTitleData.topicTitle_title = topicTitle
            topicTitleData.topicId_title = topicId
            topicTitleData.topicWithWhoDic_title = topicWithWhoDic
            topicTitleData.tag_detial = (topic_id.1 as! Dictionary<String,AnyObject>)["hash_tag"] as? Array<String>
            tempMytopicList += [topicTitleData]
        }
        
        return tempMytopicList
    }
    private func transferToStandardType_detail(_ inputData:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType> {
        // return_dic --topic_id:String
        //            --topic_contents-topic_with_who_id*- topic_with_who_name:String
        //                                               - last_speaker:String
        //                                               - img
        //                                               - is_real_pic
        //                                               - sex
        //                                               - online
        //                                               - topic_content
        //                                               - last_speaker_name
        //                                               - read
        //                                               - topic_content_id
        var tempMytopicList = [MyTopicStandardType]()
        for topicWithWhoId in inputData["topic_contents"] as! Dictionary<String,Dictionary<String,AnyObject>>{
            let topicTitleData = MyTopicStandardType(dataType:"detail")
            topicTitleData.clientId_detial = topicWithWhoId.0
            topicTitleData.topicId_title = inputData["topic_id"] as? String
            topicTitleData.clientName_detial = topicWithWhoId.1["topic_with_who_name"] as? String
            let img = base64ToImage(topicWithWhoId.1["img"] as! String)
            topicTitleData.clientPhoto_detial = img
            topicTitleData.clientIsRealPhoto_detial = topicWithWhoId.1["is_real_pic"] as? Bool
            topicTitleData.clientSex_detial = topicWithWhoId.1["sex"] as? String
            topicTitleData.clientOnline_detial = topicWithWhoId.1["online"] as? Bool
            topicTitleData.lastLine_detial = topicWithWhoId.1["topic_content"] as? String
            topicTitleData.lastSpeaker_detial = topicWithWhoId.1["last_speaker_name"] as? String
            topicTitleData.read_detial = topicWithWhoId.1["read"] as? Bool
            topicTitleData.time = time_transform_to_since1970(time_string: (topicWithWhoId.1["speak_time"] as! String))
            topicTitleData.topicTitle_title = topicWithWhoId.1["topic_title"] as? String
            let last_speaker_id = topicWithWhoId.1["last_speaker_id"] as! String
            if last_speaker_id == userData.id{
                topicTitleData.read_detial = true
            }
            topicTitleData.topicContentId_detial = String(topicWithWhoId.1["topic_content_id"] as! Int)
            
            tempMytopicList += [topicTitleData]
        }
        tempMytopicList.sort { (ta1, ta2) -> Bool in
            if ta1.time! > ta2.time!{
                return true
            }
            return false
        }
        return tempMytopicList
    }
    
        // ====add remove cell
    private func add_loaging_cell(at index:Int){
        let insertObj = MyTopicStandardType(dataType: "reloading")
        mytopic.insert(insertObj, at: index + 1)
        //delegate?.model_relodata()
        delegate?.model_insert_row(index_path_list: [IndexPath(row: index + 1, section: 0)], option: .top)
    }
    private func add_detail_cell_to_tableview(topic_id:String){
        if let title_cell_index = mytopic.index(where: { (element) -> Bool in
            if element.dataType == "title" && element.topicId_title == topic_id{
                return true
            }
            return false
        }){
            if secTopic[topic_id] != nil{
                let inputList = secTopic[topic_id]!
                var updataIndexList:Array<IndexPath> = []
                var updataIndexInt = title_cell_index as Int
                for insertData in inputList{
                    updataIndexInt += 1
                    let updataIndex = IndexPath(row: updataIndexInt, section: 0)
                    updataIndexList.append(updataIndex)
                    mytopic.insert(insertData, at: updataIndexInt)
                }
                delegate?.model_insert_row(index_path_list: updataIndexList, option: .top)
                //delegate?.model_relodata()
            }
            
        }
        
    }
    private func add_new_detail_cell_to_table(detail_cell:MyTopicStandardType){
        var last_cell_famile_index:Int?
        for cells_index in 0 ..< mytopic.count{
            if mytopic[cells_index].topicId_title! == detail_cell.topicId_title{
                last_cell_famile_index = cells_index
                break
            }
        }
        if last_cell_famile_index != nil{
            mytopic.insert(detail_cell, at: (last_cell_famile_index! + 1))
            let index_path = IndexPath(row: (last_cell_famile_index! + 1), section: 0)
            delegate?.model_insert_row(index_path_list: [index_path], option: .top)
        }
    }
    private func remove_loading_cell() {
        var remove_loading_cell_index_list:Array<Int> = []
        var remove_loading_cell_index_path_list:Array<IndexPath> = []
        for mytopic_cell_s_index in 0..<mytopic.count{
            if mytopic[mytopic_cell_s_index].dataType == "reloading"{
                remove_loading_cell_index_list.append(mytopic_cell_s_index)
                let index_path = IndexPath(row: mytopic_cell_s_index, section: 0)
                remove_loading_cell_index_path_list.append(index_path)
            }
        }
        remove_loading_cell_index_list = remove_loading_cell_index_list.reversed()
        //remove_loading_cell_index_path_list = remove_loading_cell_index_path_list.reversed()
        for remove_loading_cell_index_list_s in remove_loading_cell_index_list{
            self.mytopic.remove(at: remove_loading_cell_index_list_s)
        }
        
        delegate?.model_delete_row(index_path_list: remove_loading_cell_index_path_list, option: .none)
        
        //delegate?.model_relodata()
    }
    private func remove_detail_cell_from_tableView(){
        var remove_index_path_list:Array<IndexPath> = []
        var remove_index_int_list:Array<Int> = []
        for cells_index in 0 ..< mytopic.count{
            if mytopic[cells_index].dataType == "detail"{
                remove_index_int_list.append(cells_index)
                remove_index_path_list.append(IndexPath(row: cells_index, section: 0))
            }
        }
        if !remove_index_int_list.isEmpty{
            remove_index_int_list = remove_index_int_list.reversed()
            for remove_index_int in remove_index_int_list{
                mytopic.remove(at: remove_index_int)
            }
            delegate?.model_delete_row(index_path_list: remove_index_path_list, option: .top)
        }
        
    }
    private func remove_single_cell(at index:Int){
        mytopic.remove(at: index)
        delegate?.model_delete_row(index_path_list: [IndexPath(row:index, section:0)], option: .left)
    }
    private func remove_list_cell(topic_id:String){
        var remove_index_list:Array<Int> = []
        var remove_index_path_list:Array<IndexPath> = []
        for cells_index in 0 ..< mytopic.count{
            if mytopic[cells_index].topicId_title! == topic_id{
                remove_index_list.append(cells_index)
                remove_index_path_list.append(IndexPath(row:cells_index, section:0))
            }
        }
        remove_index_list = remove_index_list.reversed()
        for remove_index in remove_index_list{
            mytopic.remove(at: remove_index)
        }
        delegate?.model_delete_row(index_path_list: remove_index_path_list, option: .left)
    }
    private func replace_or_add_title_cell_with_new(new_title_cell:MyTopicStandardType){
        DispatchQueue.main.async {
            let topic_id = new_title_cell.topicId_title!
            //new_title_cell.dataType
            if let old_title_cell_index = self.mytopic.index(where: { (element) -> Bool in
                if element.dataType == "title" && element.topicId_title == topic_id{
                    return true
                }
                return false
            }){
                self.mytopic.remove(at: old_title_cell_index as Int)
                self.mytopic.insert(new_title_cell, at: old_title_cell_index as Int)
                let index_path = IndexPath(row: old_title_cell_index as Int, section: 0)
                //self.delegate?.model_relod_row(index_path_list: [index_path], option: .none)
            }
            else{
                let index_path = IndexPath(row: (self.mytopic.count), section: 0)
                self.mytopic.append(new_title_cell)
                //self.delegate?.model_insert_row(index_path_list: [index_path], option: .top)
            }
        }
    }
    
        // ====operate local database
    private func remove_topic_detail_data_from_local(topic_id:String){
        if secTopic[topic_id] != nil{
            secTopic[topic_id] = nil
        }
    }
    private func remove_singel_detail_data_from_local(topic_id:String, client_id:String){
        if let data_base = secTopic[topic_id]{
            if let remove_index = data_base.index(where: { (element) -> Bool in
                if element.clientId_detial == client_id{
                    return true
                }
                return false
            }){
                secTopic[topic_id]!.remove(at: remove_index as Int)
            }
        }
    }
    private func set_detail_cell_to_read(topic_id:String, client_id:String){
        let detail_cell_list = secTopic[topic_id]!
        if let detail_cell_index = detail_cell_list.index(where: { (element) -> Bool in
            if element.clientId_detial == client_id{
                return true
            }
            return false
        }){
            let detail_cell = secTopic[topic_id]![detail_cell_index]
            detail_cell.read_detial = true
        }
    }
    
        // ====logic func
    private func update_title_unread(topic_id:String){
        if let target_list_cell_index = mytopic.index(where: { (element) -> Bool in
            if element.topicId_title == topic_id{
                return true
            }
            return false
        }){
            let target_list_cell = mytopic[target_list_cell_index]
            var new_replace_dic:Dictionary<String,Bool> = [:]
            if let detail_cell_database = secTopic[topic_id]{
                for detail_cell_data in detail_cell_database{
                    new_replace_dic[detail_cell_data.clientId_detial!] = detail_cell_data.read_detial!
                }
                target_list_cell.topicWithWhoDic_title = new_replace_dic
                //let index_path = IndexPath(row: target_list_cell_index as Int, section: 0)
                //delegate?.model_relod_row(index_path_list: [index_path], option: .fade)
                delegate?.model_relodata()
            }
        }
    }
    private func find_client_id(id_1:String, id_2:String) -> String{
        if id_1 == userData.id{
            return id_2
        }
        return id_1
    }
    private func update_online_state_in_sec_topic(client_id:String, new_online_state:Bool){
        for detail_cell_list_keys in secTopic.keys{
            if let detail_cell_index = secTopic[detail_cell_list_keys]?.index(where: { (element) -> Bool in
                if element.clientId_detial == client_id{
                    return true
                }
                return false
            }){
                secTopic[detail_cell_list_keys]?[detail_cell_index].clientOnline_detial = new_online_state
                delegate?.model_relodata()
            }
        }
    }
    
}




