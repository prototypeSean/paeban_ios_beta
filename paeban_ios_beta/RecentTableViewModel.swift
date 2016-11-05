//
//  RecentTableViewModel.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/8/31.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class RecentTableViewModel{
    var recentDataBase:Array<MyTopicStandardType>{
        get{
            return addEffectiveData(nowTopicCellList)
        }
    }
    
    func reCheckDataBase() {
        let sentData:NSDictionary = [
        "msg_type":"recentDataCheck"
        ]
        socket.write(data:json_dumps(sentData))
    }
    
//    func updataNowTopicCellList(returmDic:NSDictionary){
//        for datas in returmDic{
//            transformStaticType(datas.key as! String,inputData: datas.value as! Dictionary<String,AnyObject>)
//        }
//    }
    
    func transformStaticType(_ inputKey:String,inputData:Dictionary<String,AnyObject>,reloar:@escaping ()->Void){
        if let nowTopicCellListIndex = nowTopicCellList.index(where: { (target) -> Bool in
            if target.topicId_title == inputKey{
                return true
            }
            else{
                return false
            }
        }){
            let operatingObj = nowTopicCellList[nowTopicCellListIndex]
            operatingObj.lastLine_detial = inputData["last_line"] as? String
            operatingObj.lastSpeaker_detial = inputData["last_speaker"] as? String
            operatingObj.topicContentId_detial = inputData["topic_content_id"] as? String
            operatingObj.read_detial = inputData["is_read"] as? Bool
            nowTopicCellList[nowTopicCellListIndex] = operatingObj
            reloar()
            
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
            reloar()
            HttpRequestCenter().getBlurImg(httpSendDic, InViewAct: { (returnData) in
                ouputObj.clientPhoto_detial = base64ToImage(returnData["data"] as! String)
                reloar()
            })
            
            
            
            //ouputObj.clientPhoto_detial = UIImage.init(data: data)
            
            nowTopicCellList.append(ouputObj)
            
        }
        
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
        cell.isMyPic.image = UIImage(named:"True_photo")
        if topicWriteToRow.clientIsRealPhoto_detial!{
            cell.isMyPic.tintColor = UIColor.white
        }
        else{
            cell.isMyPic.tintColor = UIColor.clear
        }
        // 發話人標籤
        var lastSpeakerName:String?
        if topicWriteToRow.lastSpeaker_detial! == userData.id{
            lastSpeakerName = userData.name
        }
        else{
            lastSpeakerName = topicWriteToRow.clientName_detial
        }
        cell.lastSpeaker.text = "\(lastSpeakerName!):"
        
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
        cell.battery.image = UIImage(named:"battery-half")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.battery.tintColor = UIColor(red:1.00, green:0.77, blue:0.18, alpha:1.0)
        return cell
    }
    
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
    
//    func updataDB(newDic:Dictionary<String,AnyObject>){
//        for newDic_s in newDic{
//            let unpackData = newDic_s.1 as! Dictionary<String,AnyObject>
//            if let newlist = self.updataLastList(recentDataBase,newDic:unpackData){
//                recentDataBase = newlist
//            }
//        }
//    }
    
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
    
    func getSegueData(_ indexInt:Int) -> Dictionary<String,AnyObject>{
        var topicViewCon:Dictionary<String,AnyObject> = [:]
        topicViewCon["topicId"] = recentDataBase[indexInt].topicId_title as AnyObject?
        topicViewCon["ownerId"] = recentDataBase[indexInt].clientId_detial as AnyObject?
        topicViewCon["ownerImg"] = recentDataBase[indexInt].clientPhoto_detial
        topicViewCon["topicTitle"] = recentDataBase[indexInt].topicTitle_title as AnyObject?
        topicViewCon["title"] = recentDataBase[indexInt].clientName_detial as AnyObject?
        return topicViewCon
    }
}

