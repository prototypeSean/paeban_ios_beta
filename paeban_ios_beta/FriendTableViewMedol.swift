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
        
        
        
        let data = friendsList[index]
        
        cell.photo.image = data.photo
        cell.truePhoto.image = UIImage(named:"True_photo")
        if data.isRealPhoto!{
            cell.truePhoto.tintColor = UIColor.white
        }
        else{
            cell.truePhoto.tintColor = UIColor.clear
        }
//        cell.sexImg.image = letoutSexLogo(data.sex!)
        cell.name.text = data.name
        cell.onlineImg.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        if data.online!{
            cell.onlineImg.tintColor = UIColor(red:0.15, green:0.88, blue:0.77, alpha:1.0)
        }
        else{
            cell.onlineImg.tintColor = UIColor.lightGray
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







