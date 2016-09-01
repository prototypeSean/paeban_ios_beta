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
    var recentDataBase:Array<MyTopicStandardType> = []
    
    init(data:Array<MyTopicStandardType>){
        self.recentDataBase = addEffectiveData(data)
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
    
}






