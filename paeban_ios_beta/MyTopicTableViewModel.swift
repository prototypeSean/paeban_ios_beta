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
    //var mytopic_shadow:Array<MyTopicStandardType> = []
    var mytopic:Array<MyTopicStandardType> = []
//        {
//        get{return mytopic_shadow}
//        set{
//            mytopic_shadow = newValue
//            var sss:Array<String> = []
//            for c in newValue{
//                sss.append(c.dataType)
//            }
//        }
//    }
    // 本地端子cell資料庫
    var secTopic:Dictionary = [String: [MyTopicStandardType]]()
    var delegate:MyTopicTableViewModelDelegate?
    var topic_id_wait_to_extend_detail_cell:String?
    var auto_leap_data_dic:Dictionary<String,String> = [:]
    var chat_view:MyTopicViewController?
    
    
    
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
                    self.replace_title_cell_with_new(new_title_cell: new_title_cell_s)
                }
                aftre_update(title_cell_list)
            }
        }
    }
    func update_detail_cell(topic_id:String,aftre_update:@escaping(_ detail_cell_list:Array<MyTopicStandardType>)->Void){
        self.get_my_topic_detail(topic_id, after_get_detail: { (detail_cell_list) in
            if self.check_detail_cell_is_need_update(topic_id: topic_id, check_data: detail_cell_list){
                self.secTopic[topic_id] = detail_cell_list
                aftre_update(detail_cell_list)
            }
        })
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
                if self.check_detail_cell_has_been_load(topic_id: select_cell.topicId_title!){
                    self.remove_detail_cell_from_tableView()
                    self.add_detail_cell_to_tableview(topic_id: select_cell.topicId_title!)
                }
                else{
                    add_loaging_cell(at: index)
                    self.topic_id_wait_to_extend_detail_cell = select_cell.topicId_title!
                    DispatchQueue.global(qos: .background).async {
                        sleep(5)
                        if !self.check_detail_cell_has_been_load(topic_id: select_cell.topicId_title!){
                            print("=======check_detail_cell_has_been_load_nil==========")
                            self.update_detail_cell(topic_id: select_cell.topicId_title!, aftre_update: { (detail_cell_list) -> Void in
                                if self.topic_id_wait_to_extend_detail_cell == select_cell.topicId_title!{
                                    self.topic_id_wait_to_extend_detail_cell = nil
                                    self.remove_detail_cell_from_tableView()
                                    self.remove_loading_cell()
                                    self.add_detail_cell_to_tableview(topic_id: select_cell.topicId_title!)
                                }
                            })
                        }
                    }
                }
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
        //send mgs to server
    }
    func delete_detail_cell(index:Int){
        let topic_id = mytopic[index].topicId_title!
        let client_id = mytopic[index].clientId_detial!
        self.remove_single_cell(at: index)
        self.remove_singel_detail_fata_from_local(topic_id: topic_id, client_id: client_id)
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
                    // MARK: testing
                    localData.read_detial = false
                    print("====chat_view====")
                    print(chat_view?.setID)
                    
                    secTopic[topic_id]!.remove(at: localData_index!)
                    secTopic[topic_id]!.insert(localData, at: localData_index!)
                    let uiDataIndex = mytopic.index(where: { (MyTopicStandardType) -> Bool in
                        if MyTopicStandardType.topicId_title == topic_id
                            && MyTopicStandardType.clientId_detial == topicWithWho{
                            return true
                        }
                        else{return false}
                    })
                    if uiDataIndex != nil{
                        mytopic.remove(at: Int(uiDataIndex!))
                        mytopic.insert(localData, at: uiDataIndex!)
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
                        self.secTopic[topic_id]?.append(cell_obj)
                        
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
    
    
    
    // ====tool func====
        // get internet data
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
                    let detial_cell_data = self.transferToStandardType_detail(returnData)
                    after_get_detail(detial_cell_data)
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
    
        // ====check func
    private func check_detail_cell_is_need_update(topic_id:String, check_data:Array<MyTopicStandardType>) -> Bool{
        if self.secTopic[topic_id] == nil{
            return true
        }
        else{
            for check_data_s in check_data{
                if let _ = self.secTopic[topic_id]?.index(where: { (element) -> Bool in
                    if check_data_s.clientId_detial == element.clientId_detial{
                        return true
                    }
                    return false
                }){
                    //pass
                }
                else{return true}
            }
            return false
        }
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
        // ====data type transfer
    private func transferToStandardType_title(_ inputData:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>{
        // return_dic = topic_id* -- topic_title : String
        //                        -- topics               -- topic_with_who_id* -- read:Bool
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
            topicTitleData.topicContentId_detial = String(topicWithWhoId.1["topic_content_id"] as! Int)
            
            tempMytopicList += [topicTitleData]
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
    private func add_new_detail_cell_to_table(detail_cell:MyTopicStandardType){
        var last_cell_famile_index:Int?
        for cells_index in 0 ..< mytopic.count{
            if mytopic[cells_index].topicId_title! == detail_cell.topicId_title{
                last_cell_famile_index = cells_index
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
    private func replace_title_cell_with_new(new_title_cell:MyTopicStandardType){
        let topic_id = new_title_cell.topicId_title!
        //new_title_cell.dataType
        if let old_title_cell_index = mytopic.index(where: { (element) -> Bool in
            if element.dataType == "title" && element.topicId_title == topic_id{
                return true
            }
            return false
        }){
            DispatchQueue.main.async {
                self.mytopic.remove(at: old_title_cell_index as Int)
                self.mytopic.insert(new_title_cell, at: old_title_cell_index as Int)
                let index_path = IndexPath(row: old_title_cell_index as Int, section: 0)
                self.delegate?.model_relod_row(index_path_list: [index_path], option: .none)
            }
            
        }
        else{
            DispatchQueue.main.async {
                let index_path = IndexPath(row: (self.mytopic.count), section: 0)
                self.mytopic.append(new_title_cell)
                self.delegate?.model_insert_row(index_path_list: [index_path], option: .top)
            }
            
        }
    }
    
        // ====operate local database
    private func remove_topic_detail_data_from_local(topic_id:String){
        if secTopic[topic_id] != nil{
            secTopic[topic_id] = nil
        }
    }
    private func remove_singel_detail_fata_from_local(topic_id:String, client_id:String){
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
    
    // ======施工中=====
    
    
    
    // ======施工中=====
    
    
}



