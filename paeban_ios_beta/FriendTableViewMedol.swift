//
//  FriendTableViewMedol.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class FriendTableViewMedol{
    var friendsList:Array<FriendStanderType>{
        get{
            return myFriendsList
        }
    }
    
    func getDataCount() -> Int{
        return friendsList.count
    }
    
    func getCell(_ index:Int,cell:FriendTableViewCell) -> FriendTableViewCell {
        func letoutSexLogo(_ sex:String) -> UIImage {
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
        func letoutIsTruePhoto(_ isTruePhoto:Bool) -> UIImage {
            var isMeImg:UIImage
            if isTruePhoto{isMeImg = UIImage(named:"True_photo")!}
            else{isMeImg = UIImage(named:"Fake_photo")!}
            return isMeImg
        }
        func letoutOnlineImg(_ online:Bool) -> UIImageView{
            let onlineimage = UIImageView()
            
            onlineimage.image = UIImage(named:"texting")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            if online{
                onlineimage.tintColor = UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
            }
            else{
                onlineimage.tintColor = UIColor.gray
            }
            return onlineimage
        }
        
        let data = friendsList[index]
        
        cell.photo.image = data.photo
        cell.truePhoto.image = letoutIsTruePhoto(data.isRealPhoto!)
        cell.sexImg.image = letoutSexLogo(data.sex!)
        cell.name.text = data.name
        cell.onlineImg.image = UIImage(named:"texting")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        if data.online!{
            cell.onlineImg.tintColor = UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
        }
        else{
            cell.onlineImg.tintColor = UIColor.gray
        }
        
        
        return cell
    }
    
    func getSegueData(_ index:Int) -> Dictionary<String,AnyObject>{
        var returnDic:Dictionary<String,AnyObject> = [:]
        let dataSouse = friendsList[index]
        returnDic["clientId"] = dataSouse.id as AnyObject?
        returnDic["clientName"] = dataSouse.name as AnyObject?
        returnDic["clientImg"] = dataSouse.photo
        return returnDic
    }
    
    func turnToMessage3(_ inputDic:Dictionary<String,AnyObject>) -> JSQMessage3{
        let returnObj = JSQMessage3(senderId: inputDic["senderId"] as! String,
                                    displayName: inputDic["displayName"] as! String,
                                    text: inputDic["text"] as! String)
        returnObj?.topicId = inputDic["topicId"] as? String
        returnObj?.topicTempid = inputDic["topicTempid"] as? String
        returnObj?.isRead = inputDic["isRead"] as? Bool
        return returnObj!
    }
    
}







