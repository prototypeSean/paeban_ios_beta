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
    // controller func
    func reCheckDataBase() {
        get_recent_data()
        
    }
    func recive_topic_msg(msg:Dictionary<String,AnyObject>){
        update_last_line(msg: msg)
    }
    func getCell(_ index:Int,cell:RecentTableViewCell) -> RecentTableViewCell{
        func letoutSexLogo(_ sex:String!) -> UIImage {
            var sexImg:UIImage
            switch sex {
            case "男":
                sexImg = UIImage(named: "male")!
            case "女":
                sexImg = UIImage(named:"female")!
            case "男同":
                sexImg = UIImage(named:"gay")!
            case "女同":
                sexImg = UIImage(named:"lesbain")!
            default:
                sexImg = UIImage(named: "male")!
                print("性別圖示分類失敗")
            }
            return sexImg
        }
        // 沒作用
        //        func letoutIsTruePhoto(_ isTruePhoto:Bool) -> UIImageView {
        //            let isMeImg = UIImageView()
        //            isMeImg.image = UIImage(named:"True_photo")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        //
        //            return isMeImg
        //        }
        // 沒作用
        //        func letoutOnlineImg(_ online:Bool) -> UIImageView{
        //            let onlineimage = UIImageView()
        //            onlineimage.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        //            return onlineimage
        //        }
        
        // 麻煩的東西這邊才開始畫外觀
        let topicWriteToRow = recentDataBase[index]
        //print(topicWriteToRow.topicTitle_title)
        
        // Hashtag
        cell.hashtag.tagListInContorller = topicWriteToRow.tag_detial
        cell.hashtag.drawButton()
        // 照片，但是設定圓角在VC
        cell.clientImg.image = topicWriteToRow.clientPhoto_detial
        // 性別圖示
        cell.clientSex.image = letoutSexLogo(topicWriteToRow.clientSex_detial!)
        // 本人照片圖示
        cell.isMyPic.image = UIImage(named:"True_photo")!.withRenderingMode(.alwaysTemplate)
        if topicWriteToRow.clientIsRealPhoto_detial!{
            cell.isMyPic.tintColor = UIColor.white
        }
        else{
            cell.isMyPic.tintColor = UIColor.clear
        }
        // 發話人標籤
        var lastSpeakerName:String?
        print(topicWriteToRow.lastSpeaker_detial)
        print(topicWriteToRow.read_detial)
        if topicWriteToRow.lastSpeaker_detial! == userData.name{
            lastSpeakerName = userData.name
            
        }
        else{
            lastSpeakerName = topicWriteToRow.clientName_detial
            if topicWriteToRow.read_detial == false{
                cell.lastLine.textColor = UIColor(red:0.99, green:0.38, blue:0.27, alpha:1.0)
            }
            else{
                cell.lastLine.textColor = nil
            }
            
        }
        cell.lastSpeaker.text = "\(lastSpeakerName!):"
        print(cell.lastSpeaker.text )
        print("=====")
        // 話題owner
        cell.ownerName.text = topicWriteToRow.clientName_detial
        // 最新一句對話
        cell.lastLine.text = topicWriteToRow.lastLine_detial
        
        
        
        cell.online.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        if topicWriteToRow.clientOnline_detial!{
            cell.online.tintColor = UIColor(red:0.15, green:0.88, blue:0.77, alpha:1.0)
        }
        else{
            
            cell.online.tintColor = UIColor.lightGray
        }
        cell.battery.image = UIImage(named:"battery-half")
        //        cell.battery.tintColor = UIColor(red:1.00, green:0.77, blue:0.18, alpha:1.0)
        return cell
    }
    func clientOnline(_ msg:Dictionary<String,AnyObject>) -> Bool{
        var dataChange = false
        let onLineUser = msg["user_id"] as! String
        if let _ = recentDataBase.index(where: { (target) -> Bool in
            if target.clientId_detial == onLineUser{
                return true
            }
            else{return false}
        }){
            //            for recentDataBaseIndex in 0..<recentDataBase.count{
            //                if onLineUser == recentDataBase[recentDataBaseIndex].clientId_detial{
            //                    recentDataBase[recentDataBaseIndex].clientOnline_detial = true
            //                }
            //            }
            dataChange = true
        }
        return dataChange
    }
    func clientOffline(_ msg:Dictionary<String,AnyObject>) -> Bool{
        let offLineUser = msg["user_id"] as! String
        var dataChange = false
        if let _ = recentDataBase.index(where: { (target) -> Bool in
            if target.clientId_detial == offLineUser{
                return true
            }
            else{return false}
        }){
            //            for recentDataBaseIndex in 0..<recentDataBase.count{
            //                if offLineUser == recentDataBase[recentDataBaseIndex].clientId_detial{
            //                    recentDataBase[recentDataBaseIndex].clientOnline_detial = false
            //                }
            //            }
            dataChange = true
        }
        return dataChange
    }
    func topicClosed(_ msg:Dictionary<String,AnyObject>) -> Bool{
        var dataChanged = false
        if let _ = msg["topic_id"] as? Array<String>{
            //            var removeTopicIndexList:Array<Int> = []
            //            for closeTopicId in topicIdList{
            //                let closeTopicIndex = recentDataBase.indexOf({ (target) -> Bool in
            //                    if target.topicId_title == closeTopicId{
            //                        return true
            //                    }
            //                    else{return false}
            //                })
            //                if closeTopicIndex != nil{
            //                    removeTopicIndexList.append(closeTopicIndex! as Int)
            //                }
            //            }
            //            removeTopicIndexList = removeTopicIndexList.sort(>)
            //            for removeTopicIndex in removeTopicIndexList{
            //                recentDataBase.removeAtIndex(removeTopicIndex)
            //            }
            dataChanged = true
        }
        return dataChanged
    }
    
    // 施工中
    private func update_last_line(msg:Dictionary<String,AnyObject>){
        if let result_dic = msg["result_dic"] as? Dictionary<String,Dictionary<String,String>>{
            for topic_content_id in result_dic{
                let topic_content_data = topic_content_id.1
                let client_id = find_client_id(id1: topic_content_data["sender"]!, id2: topic_content_data["receiver"]!)
                if let target_cell_index = find_target_cell_index(topic_id: topic_content_data["topic_id"]!, client_id: client_id){
                    let target_cell = recentDataBase[target_cell_index]
                    target_cell.lastLine_detial = topic_content_data["topic_content"]!
                    if chat_view?.ownerId == client_id{
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
    func find_target_cell_index(topic_id:String,client_id:String) -> Int?{
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
    func find_client_id(id1:String,id2:String) -> String{
        if id1 == userData.id{
            return id2
        }
        return id1
    }
    
    // internet
    private func get_recent_data(){
        HttpRequestCenter().request_user_data("recent_data", send_dic: [:]) { (retuen_dic) in
            let data = retuen_dic["data"] as! Dictionary<String,AnyObject>
            for datas in data{
                self.transformStaticType(datas.0, inputData: datas.1 as! Dictionary<String,AnyObject>)
            }
        }
    }
    // transform
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
            recentDataBase[recentDataBaseIndex] = operatingObj
            DispatchQueue.main.async {
                self.delegate?.model_relodata()
            }
            
            
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
            ouputObj.clientOnline_detial = inputData["owner_online"] as? Bool
            ouputObj.tag_detial = inputData["tag_list"] as? Array<String>
            let httpSendDic = ["client_id":inputData["owner"] as! String,
                               "topic_id":inputKey]
            DispatchQueue.main.async {
                self.delegate?.model_relodata()
            }
            HttpRequestCenter().getBlurImg(httpSendDic, InViewAct: { (returnData) in
                ouputObj.clientPhoto_detial = base64ToImage(returnData["data"] as! String)
                DispatchQueue.main.async {
                    self.delegate?.model_relodata()
                }
            })
            //ouputObj.clientPhoto_detial = UIImage.init(data: data)
            recentDataBase.append(ouputObj)
        }
        
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

