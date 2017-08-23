//
//  RecentTableViewModel.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/8/31.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit
protocol RecentTableViewModelDelegate {
    func model_relodata()
    func model_relod_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation)
    func model_delete_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation)
    func model_insert_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation)
    func segue_to_chat_view(detail_cell_obj:MyTopicStandardType)
}


class RecentTableViewModel{
    var recentDataBase:Array<MyTopicStandardType> = []
    var segueDataIndex:Int?
    var delegate:RecentTableViewModelDelegate?
    var chat_view:TopicViewController?
    var leave_topic_master_list:Array<Dictionary<String,String>> = []
    var last_check_online_time:TimeInterval?
    
    // controller func
    func reCheckDataBase() {
        recentDataBase = []
        get_recent_data()
        updata_online_state()
        update_battery_state()
    }
    func recive_topic_msg(msg:Dictionary<String,AnyObject>){
        update_last_line(msg: msg)
    }
    func getCell(_ index:Int,cell:RecentTableViewCell) -> RecentTableViewCell{
        func letoutSexLogo(_ sex:String!) -> UIImage {
            let sexImg: UIImage?
            switch sex {
            case "男":
                sexImg = UIImage(named: "male")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.clientSex.tintColor = UIColor(red:0.27, green:0.71, blue:0.88, alpha:1.0)
            case "女":
                sexImg = UIImage(named:"female")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.clientSex.tintColor = UIColor(red:1.00, green:0.49, blue:0.42, alpha:1.0)
            case "男同":
                sexImg = UIImage(named:"gay")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.clientSex.tintColor = UIColor(red:0.27, green:0.71, blue:0.88, alpha:1.0)
            case "女同":
                sexImg = UIImage(named:"lesbain")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.clientSex.tintColor = UIColor(red:1.00, green:0.49, blue:0.42, alpha:1.0)
            default:
                sexImg = UIImage(named: "male")!
                print("性別圖示分類失敗")
            }
            return sexImg!
        }
        
        // 麻煩的東西這邊才開始畫外觀
        let topicWriteToRow = recentDataBase[index]
        
        
        // Hashtag
        cell.hashtag.tagListInContorller = topicWriteToRow.tag_detial
        cell.hashtag.drawButton()
        // 照片，但是設定圓角在VC
        cell.clientImg.image = topicWriteToRow.clientPhoto_detial
        // 性別圖示
        if topicWriteToRow.clientSex_detial != nil{
            cell.clientSex.image = letoutSexLogo(topicWriteToRow.clientSex_detial!)
        }
        // 本人照片圖示
        cell.isMyPic.image = UIImage(named:"True_photo")!.withRenderingMode(.alwaysTemplate)
        if topicWriteToRow.clientIsRealPhoto_detial != nil{
            if topicWriteToRow.clientIsRealPhoto_detial!{
                cell.isMyPic.tintColor = UIColor.white
            }
            else{
                cell.isMyPic.tintColor = UIColor.clear
            }
        }
        
        // 發話人標籤
        var lastSpeakerName:String?
        
        if topicWriteToRow.lastSpeaker_detial! == userData.id{
            lastSpeakerName = userData.name
            cell.lastLine.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
//            cell.lastLine.font = UIFont.systemFont(ofSize: 13)
        }
        else{
            lastSpeakerName = topicWriteToRow.clientName_detial
            if topicWriteToRow.read_detial == false{
                cell.lastLine.textColor = UIColor(red:0.97, green:0.49, blue:0.31, alpha:1.0)
//                cell.lastLine.font = UIFont.boldSystemFont(ofSize: 13)
            }
            else{
                cell.lastLine.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
//                cell.lastLine.font = UIFont.systemFont(ofSize: 13)
            }
            
        }
        if lastSpeakerName != nil{
           cell.lastSpeaker.text = "\(lastSpeakerName!)"
        }
        // 話題owner
        cell.ownerName.text = topicWriteToRow.clientName_detial
        // 最新一句對話
        cell.lastLine.text = topicWriteToRow.lastLine_detial
        cell.online.layoutIfNeeded()
        cell.online.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let cr = (cell.online.frame.size.width)/2
        cell.online.layer.borderWidth = 1
        cell.online.layer.borderColor = UIColor.white.cgColor
        cell.online.layer.cornerRadius = cr
        cell.online.clipsToBounds = true
        if topicWriteToRow.clientOnline_detial != nil{
            if topicWriteToRow.clientOnline_detial!{
                cell.online.tintColor = UIColor(red:0.15, green:0.88, blue:0.77, alpha:1.0)
            }
            else{
                
                cell.online.tintColor = UIColor.lightGray
            }
        }
        if topicWriteToRow.battery != nil{
            letoutBattery(battery: cell.battery, batteryLeft: topicWriteToRow.battery!)
        }
        return cell
    }
    func letoutBattery(battery:UIImageView, batteryLeft:Int){
        if batteryLeft <= 30{
            battery.image = UIImage(named:"battery-low")
        }
        else if batteryLeft <= 50{
            battery.image = UIImage(named:"battery-half")
        }
        else if batteryLeft <= 80{
            battery.image = UIImage(named:"battery-good")
        }
        else if batteryLeft <= 100{
            battery.image = UIImage(named:"battery-full")
        }
    }
    func clientOnline(_ msg:Dictionary<String,AnyObject>) -> Bool{
        var dataChange = false
        let onLineUser = msg["user_id"] as! String
        if let data_index = recentDataBase.index(where: { (target) -> Bool in
            if target.clientId_detial == onLineUser{
                return true
            }
            else{return false}
        }){
            recentDataBase[data_index].clientOnline_detial = true
            dataChange = true
        }
        return dataChange
    }
    func clientOffline(_ msg:Dictionary<String,AnyObject>) -> Bool{
        let offLineUser = msg["user_id"] as! String
        var dataChange = false
        if let data_index = recentDataBase.index(where: { (target) -> Bool in
            if target.clientId_detial == offLineUser{
                return true
            }
            else{return false}
        }){
            recentDataBase[data_index].clientOnline_detial = false
            dataChange = true
        }
        return dataChange
    }
    func topicClosed(_ msg:Dictionary<String,AnyObject>) -> Bool{
        var dataChanged = false
        if let topic_id = msg["topic_id"] as? String{
            sql_database.delete_recent_topic(topic_id_in: topic_id)
            if let data_index = recentDataBase.index(where: { (target) -> Bool in
                if target.topicId_title == topic_id{
                    return true
                }
                else{return false}
            }){
                recentDataBase.remove(at: data_index)
                dataChanged = true
            }
            dataChanged = true
        }
        return dataChanged
    }
//    func add_leave_topic_table(index:Int){
//        let topic_id = recentDataBase[index].topicId_title!
//        sql_database.add_topic_to_topic_table(topic_id_input:topic_id)
//    }
//    func send_leave_topic(){
//        let send_list = sql_database.get_topic_table_list()
//        self.send_leave_topic_to_ws(data_s: send_list)
//    }
    func remove_cell(index:Int){
        recentDataBase.remove(at: index)
        let index_path = IndexPath(row: index, section: 0)
        delegate?.model_delete_row(index_path_list: [index_path], option: .left)
    }
    func remove_cell(by topic_id:String){
        if let cell_index = recentDataBase.index(where: { (element) -> Bool in
            if element.topicId_title == topic_id{
                return true
            }
            return false
        }){
            self.remove_cell(index:cell_index)
        }
    }
    func add_leave_topic_master_list(topic_id_input:String, owner_name_input:String){
        if let data_index = recentDataBase.index(where: { (element) -> Bool in
            if element.topicId_title == topic_id_input{
                return true
            }
            return false
        }){
            let topic_title = recentDataBase[data_index].topicTitle_title!
            let temp_dic = [
                "owner_name":owner_name_input,
                "topic_title":topic_title
            ]
            leave_topic_master_list.append(temp_dic)
            
        }
        
    }
    func updata_online_state(){
        let time_now = Date().timeIntervalSince1970
        if last_check_online_time == nil || time_now - last_check_online_time! > 30{
            last_check_online_time = time_now
            var client_list:Array<String> = []
            for client_data_s in recentDataBase{
                client_list.append(client_data_s.clientId_detial!)
            }
            HttpRequestCenter().inquire_online_state(client_id_list: client_list) { (return_dic:Dictionary<String, AnyObject>) in
                if !return_dic.isEmpty{
                    DispatchQueue.main.async {
                        let return_dic_copy = return_dic as! Dictionary<String,Bool>
                        for cell_datas in self.recentDataBase{
                            if let online_state = return_dic_copy[cell_datas.clientId_detial!]{
                                cell_datas.clientOnline_detial = online_state
                            }
                        }
                        self.delegate?.model_relodata()
                    }
                }
            }
        }
        
    }
    func update_battery_state(){
        var topic_id_list:Array<String> = []
        for cells in recentDataBase{
            if cells.topicId_title != nil{
                topic_id_list.append(cells.topicId_title!)
            }
        }
        HttpRequestCenter().updata_battery_state(topic_id_list: topic_id_list) { (return_dic:Dictionary<String, AnyObject>) in
            DispatchQueue.main.async {
                for cells in self.recentDataBase{
                    if cells.topicId_title != nil{
                        if return_dic[cells.topicId_title!] != nil{
                            cells.battery = Int(return_dic[cells.topicId_title!]! as! String)
                        }
                    }
                }
                self.delegate?.model_relodata()
            }
        }
    }
    // 施工中
    
    
    
    // internet
    private func send_leave_topic_to_ws(data_s:Array<String>){
        for topic_id in data_s{
            let msg_dic:NSDictionary = [
                "topic_id": topic_id
            ]
            let send_dic:NSDictionary = [
                "msg_type": "leave_topic",
                "msg": msg_dic
            ]
            socket.write(data: json_dumps(send_dic))
        }
    }
    private func find_target_cell_index(topic_id:String,client_id:String) -> Int?{
        if let index = recentDataBase.index(where: { (element) -> Bool in
            if element.topicId_title == topic_id &&
                element.clientId_detial == client_id{
                return true
            }
            return false
        }){
            return index as Int
        }
        return nil
    }
    private func find_client_id(id1:String,id2:String) -> String{
        if id1 == userData.id{
            return id2
        }
        return id1
    }
    private func update_last_line(msg:Dictionary<String,AnyObject>){
        if let result_dic = msg["result_dic"] as? Dictionary<String,Dictionary<String,String>>{
            for topic_content_id in result_dic{
                let topic_content_data = topic_content_id.1
                let sender = topic_content_data["sender"]! as String
                let client_id = find_client_id(id1: topic_content_data["sender"]!, id2: topic_content_data["receiver"]!)
                if let target_cell_index = find_target_cell_index(topic_id: topic_content_data["topic_id"]!, client_id: client_id){
                    let target_cell = recentDataBase[target_cell_index]
                    target_cell.lastLine_detial = topic_content_data["topic_content"]!
                    target_cell.lastSpeaker_detial = topic_content_data["sender_name"]!
                    if userData.id == sender{
                        target_cell.read_detial = true
                    }
                    else{
                        target_cell.read_detial = false
                    }
                    delegate?.model_relodata()
                }
            }
        }
        
        if msg["img"] != nil{
            //let img = base64ToImage(msg["img"] as! String)
        }
    }
    private func get_recent_data(){
        let result_data = sql_database.get_recent_last_line()
        draw_basic_cell(input_dic: result_data)
        self.sort_recent_db_by_time()
        get_client_data()
        //get_client_data_from_server(client_list_for_request: client_list_for_request)
        //self.delegate?.model_relodata()
    }
    private func get_client_data(){
        for cells_index in 0..<recentDataBase.count{
            let topic_id = recentDataBase[cells_index].topicId_title!
            let client_id = recentDataBase[cells_index].clientId_detial!
            let client_data_obj = Client_detail_data(topic_id: topic_id, client_id: client_id)
            if client_data_obj.local_data_test(){
                // fly
                let client_datas = client_data_obj.get_data_from_local()
                recentDataBase[cells_index].clientName_detial = client_datas?["client_name"] as? String
                recentDataBase[cells_index].clientPhoto_detial = base64ToImage(client_datas!["img"] as! String)
                recentDataBase[cells_index].level = client_datas?["level"] as? Int
                recentDataBase[cells_index].clientSex_detial = client_datas?["sex"] as? String
                recentDataBase[cells_index].clientIsRealPhoto_detial = client_datas?["is_real_pic"] as? Bool
            }
            else{
                client_data_obj.get_client_data(act: { (client_datas:Dictionary<String, AnyObject>) in
                    if self.recentDataBase.count > cells_index && self.recentDataBase[cells_index].clientId_detial == client_datas["client_id"] as? String{
                        self.recentDataBase[cells_index].clientName_detial = client_datas["client_name"] as? String
                        self.recentDataBase[cells_index].clientPhoto_detial = base64ToImage(client_datas["img"] as! String)
                        self.recentDataBase[cells_index].level = client_datas["level"] as? Int
                        self.recentDataBase[cells_index].clientSex_detial = client_datas["sex"] as? String
                        self.recentDataBase[cells_index].clientIsRealPhoto_detial = client_datas["is_real_pic"] as? Bool
                        self.delegate?.model_relodata()
                    }
                })
            }
        }
        self.delegate?.model_relodata()
    }
    private func get_client_data_from_server(client_list_for_request:Array<Dictionary<String,AnyObject>>){
        if !client_list_for_request.isEmpty{
            for data_s in client_list_for_request{
                let detail_client_data_obj = Client_detail_data(topic_id: data_s["topic_id"] as! String, client_id: data_s["client_id"] as! String)
                detail_client_data_obj.get_client_data(act: { (return_dic:Dictionary<String, AnyObject>) in
                    self.update_cells(input_dic: return_dic)
                    self.sort_recent_db_by_time()
                    self.delegate?.model_relodata()
                })
            }
        }
    }
    private func update_cells(input_dic:Dictionary<String, AnyObject>){
        if let cell_index = recentDataBase.index(where: { (ele:MyTopicStandardType) -> Bool in
            if ele.clientId_detial == input_dic["client_id"] as? String{
                return true
            }
            return false
        }){
            recentDataBase[cell_index].clientName_detial = input_dic["client_name"] as? String
            recentDataBase[cell_index].clientPhoto_detial = base64ToImage(input_dic["img"] as! String)
            recentDataBase[cell_index].clientSex_detial = input_dic["sex"] as? String
            recentDataBase[cell_index].clientIsRealPhoto_detial = input_dic["is_real_pic"] as? Bool
            recentDataBase[cell_index].level = input_dic["level"] as? Int
        }
    }
    private func remove_out_off_data(data:Dictionary<String,AnyObject>){
        var check_topic_id_list:Array<String> = []
        for topic_id in data{
            check_topic_id_list.append(topic_id.0)
        }
        print(check_topic_id_list)
        var remove_list:Array<Int> = []
        var count_index = 0
        for cell_s in recentDataBase{
            if let _ = check_topic_id_list.index(of: cell_s.topicId_title!){
                //pass
            }
            else{
                remove_list.append(count_index)
            }
            count_index += 1
        }
        remove_list.reverse()
        for remove_index in remove_list{
            recentDataBase.remove(at: remove_index)
        }
        self.delegate?.model_relodata()
    }
    
    // 取得本機的最新資料用來更新「進行中」cell
    func update_topic_content_id() ->Dictionary<String,AnyObject>{
        let returnDic:Dictionary<String,AnyObject> = [:]
        
        return returnDic
    }
    func update_lastLine() ->Dictionary<String,AnyObject>{
        let returnDic:Dictionary<String,AnyObject> = [:]
        
        return returnDic
    }
    func update_lastLine_speaker() ->Dictionary<String,AnyObject>{
        let returnDic:Dictionary<String,AnyObject> = [:]
        
        return returnDic
    }
    func update_is_read() ->Dictionary<String,AnyObject>{
        let returnDic:Dictionary<String,AnyObject> = [:]
        
        return returnDic
    }
    func update_time() ->Dictionary<String,AnyObject>{
        let returnDic:Dictionary<String,AnyObject> = [:]
        
        return returnDic
    }
    func update_owner() ->Dictionary<String,AnyObject>{
        let returnDic:Dictionary<String,AnyObject> = [:]
        
        return returnDic
    }
    func update_topicId_title() ->Dictionary<String,AnyObject>{
        let returnDic:Dictionary<String,AnyObject> = [:]
        
        return returnDic
    }

    
    
    
    
    // transform
    func draw_basic_cell(input_dic:Dictionary<String,AnyObject>){
        for datas in input_dic{
            // 工作2 if no key "img"  add to request_img_list
            self.transformStaticType(datas.0, inputData: datas.1 as! Dictionary<String,AnyObject>)
        }
    }
    func transformStaticType(_ inputKey:String,inputData:Dictionary<String,AnyObject>){
        if let recentDataBaseIndex = recentDataBase.index(where: { (target) -> Bool in
            if target.topicId_title == inputKey{
                return true
            }
            else{
                return false
            }
        }){
            let operatingObj = recentDataBase[recentDataBaseIndex]
            operatingObj.lastLine_detial = inputData["last_line"] as? String
            operatingObj.lastSpeaker_detial = inputData["last_speaker"] as? String
            operatingObj.topicContentId_detial = inputData["topic_content_id"] as? String
            operatingObj.read_detial = inputData["is_read"] as? Bool
            operatingObj.time = inputData["time"] as? Double
            operatingObj.tag_detial = inputData["tag_list"] as? Array<String>
            operatingObj.topicTitle_title = inputData["topic_title"] as? String
            //operatingObj.battery = Int((inputData["battery"] as? String)!)
            recentDataBase[recentDataBaseIndex] = operatingObj

        }
        else{
            let ouputObj = MyTopicStandardType(dataType: "detail")
            ouputObj.topicId_title = inputKey
            ouputObj.topicTitle_title = inputData["topic_title"] as? String
            ouputObj.clientId_detial = inputData["owner"] as? String
            ouputObj.clientName_detial = inputData["owner_name"] as? String
            ouputObj.clientSex_detial = inputData["owner_sex"] as? String
            ouputObj.lastLine_detial = inputData["last_line"] as? String
            ouputObj.lastSpeaker_detial = inputData["last_speaker"] as? String
            ouputObj.topicContentId_detial = inputData["topic_content_id"] as? String
            ouputObj.read_detial = inputData["is_read"] as? Bool
            ouputObj.clientIsRealPhoto_detial = inputData["owner_is_real_img"] as?Bool
            //ouputObj.clientOnline_detial = inputData["owner_online"] as? Bool
            ouputObj.tag_detial = inputData["tag_list"] as? Array<String>
            ouputObj.time = inputData["time"] as? Double
            //ouputObj.clientOnline_detial = false
            //ouputObj.battery = Int((inputData["battery"] as? String)!)
//            let httpSendDic = ["client_id":inputData["owner"] as! String,
//                               "topic_id":inputKey]
//            HttpRequestCenter().getBlurImg(httpSendDic, InViewAct: { (returnData) in
//                ouputObj.clientPhoto_detial = base64ToImage(returnData["data"] as! String)
//                DispatchQueue.main.async {
//                    self.sort_recent_db_by_time()
//                    self.delegate?.model_relodata()
//                }
//            })
            //ouputObj.clientPhoto_detial = UIImage.init(data: data)
            recentDataBase.append(ouputObj)
        }
        
    }
    func sort_recent_db_by_time(){
        recentDataBase.sort(by: { (obj1, obj2) -> Bool in
            if obj1.time != nil && obj2.time != nil{
                if obj1.time! > obj2.time!{
                    return true
                }
                return false
            }
            return false
        })
    }
    
    
    // 未分類
    func lenCount() -> Int {
        return recentDataBase.count
    }
    func addEffectiveData(_ inputData:Array<MyTopicStandardType>) -> Array<MyTopicStandardType>{
        var returnList:Array<MyTopicStandardType> = []
        for datas in inputData {
            if datas.lastLine_detial != nil{
                returnList.append(datas)
            }
        }
        return returnList
    }
    
    fileprivate func updataLastList(_ dataBase:Array<MyTopicStandardType>,newDic:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>?{
        var topicWho = newDic["sender"] as! String
        var returnData = dataBase
        if topicWho == userData.id{
            topicWho = newDic["receiver"] as! String
        }
        
        if let dataIndex = returnData.index(where: { (target) -> Bool in
            
            if target.clientId_detial! == topicWho
                && target.topicId_title! == newDic["topic_id"] as! String{
                return true
            }
            else{return false}
        }){
            returnData[dataIndex].lastLine_detial = newDic["topic_content"] as? String
            returnData[dataIndex].lastSpeaker_detial = newDic["sender"] as? String
            return returnData
        }
        else{return nil}
    }

    func getSegueData(_ indexInt:Int) -> Dictionary<String,AnyObject>{
        var topicViewCon:Dictionary<String,AnyObject> = [:]
        topicViewCon["topicId"] = recentDataBase[indexInt].topicId_title as AnyObject?
        
        topicViewCon["ownerId"] = recentDataBase[indexInt].clientId_detial as AnyObject?
        topicViewCon["ownerName"] = recentDataBase[indexInt].clientName_detial as AnyObject?
        topicViewCon["ownerImg"] = recentDataBase[indexInt].clientPhoto_detial
        topicViewCon["topicTitle"] = recentDataBase[indexInt].topicTitle_title as AnyObject?
        topicViewCon["title"] = recentDataBase[indexInt].clientName_detial as AnyObject?
        return topicViewCon
    }
}

