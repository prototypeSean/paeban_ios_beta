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
    
    func getCell(index:Int,cell:RecentTableViewCell) -> RecentTableViewCell{
        func letoutSexLogo(sex:String) -> UIImage {
            var sexImg:UIImage
            switch sex {
            case "男":
                sexImg = UIImage(named: "male")!
            case "女":
                sexImg = UIImage(named:"gay")!
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
        func letoutIsTruePhoto(isTruePhoto:Bool) -> UIImage {
            var isMeImg:UIImage
            if isTruePhoto{isMeImg = UIImage(named:"True_photo")!}
            else{isMeImg = UIImage(named:"Fake_photo")!}
            return isMeImg
        }
        func letoutOnlineImg(online:Bool) -> UIImageView{
            let onlineimage = UIImageView()
            
            onlineimage.image = UIImage(named:"texting")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            if online{
                onlineimage.tintColor = UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
            }
            else{
                onlineimage.tintColor = UIColor.grayColor()
            }
            return onlineimage
        }
        
        let topicWriteToRow = recentDataBase[index]
        
        
        cell.hashtag.tagListInContorller = topicWriteToRow.tag_detial
        cell.hashtag.drawButton()
        
        cell.clientImg.image = topicWriteToRow.clientPhoto_detial
        cell.clientSex.image = letoutSexLogo(topicWriteToRow.clientSex_detial!)
        cell.isMyPic.image = letoutIsTruePhoto(topicWriteToRow.clientIsRealPhoto_detial!)
        
        var lastSpeakerName:String?
        if topicWriteToRow.lastSpeaker_detial! == userData.id{
            lastSpeakerName = userData.name
        }
        else{
            lastSpeakerName = topicWriteToRow.clientName_detial
        }
        cell.lastSpeaker.text = "\(lastSpeakerName!):"
        
        cell.ownerName.text = topicWriteToRow.clientName_detial
        
        cell.lastLine.text = topicWriteToRow.lastLine_detial
        
        cell.online.image = UIImage(named:"texting")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        if topicWriteToRow.clientOnline_detial!{
            cell.online.tintColor = UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
        }
        else{
            cell.online.tintColor = UIColor.grayColor()
        }        
        
        return cell
    }
    
    func lenCount() -> Int {
        return recentDataBase.count
    }
    
    func addEffectiveData(inputData:Array<MyTopicStandardType>) -> Array<MyTopicStandardType>{
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
    
    private func updataLastList(dataBase:Array<MyTopicStandardType>,newDic:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>?{
        var topicWho = newDic["sender"] as! String
        var returnData = dataBase
        if topicWho == userData.id{
            topicWho = newDic["receiver"] as! String
        }
        
        if let dataIndex = returnData.indexOf({ (target) -> Bool in
            
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
    
    func clientOnline(msg:Dictionary<String,AnyObject>) -> Bool{
        var dataChange = false
        let onLineUser = msg["user_id"] as! String
        if let _ = recentDataBase.indexOf({ (target) -> Bool in
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

    func clientOffline(msg:Dictionary<String,AnyObject>) -> Bool{
        let offLineUser = msg["user_id"] as! String
        var dataChange = false
        if let _ = recentDataBase.indexOf({ (target) -> Bool in
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
    
    func topicClosed(msg:Dictionary<String,AnyObject>) -> Bool{
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
    
    func getSegueData(indexInt:Int) -> Dictionary<String,AnyObject>{
        var topicViewCon:Dictionary<String,AnyObject> = [:]
        topicViewCon["topicId"] = recentDataBase[indexInt].topicId_title
        topicViewCon["ownerId"] = recentDataBase[indexInt].clientId_detial
        topicViewCon["ownerImg"] = recentDataBase[indexInt].clientPhoto_detial
        topicViewCon["topicTitle"] = recentDataBase[indexInt].topicTitle_title
        topicViewCon["title"] = recentDataBase[indexInt].clientName_detial
        return topicViewCon
    }
}

