//
//  FriendStanderType.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

open class FriendStanderType{
    var cell_type:String?
    //friend, invite, list
    var id:String?
    var name:String?
    var sex:String?
    var isRealPhoto:Bool?
    var online:Bool?
    var photoHttpStr:String?
    var photo:UIImage?
    var lastLine:String?
    var last_speaker:String?
    var invite_list_count:Int?
    var online_checked = false
}

public func turnToFriendStanderType(_ id:String,name:String,sex:String,isRealPhoto:Bool,online:Bool,photoString:String) ->FriendStanderType{
    let returnObj = FriendStanderType()
    returnObj.cell_type = "friend"
    returnObj.id = id
    returnObj.name = name
    returnObj.sex = sex
    returnObj.isRealPhoto = isRealPhoto
    returnObj.online = online
    returnObj.photoHttpStr = photoString
    let test = HttpRequestCenter()
    
    test.getHttpImg("https://www.paeban.com/media/\(photoString)") { (img) in
        returnObj.photo = img
    }
    return returnObj
}

public func turnToFriendStanderType_v2(friend_dic:Dictionary<String,AnyObject>) -> Array<FriendStanderType>{
    var return_list:Array<FriendStanderType> = []
    for friend_name in friend_dic.keys{
        let temp_cell = FriendStanderType()
        temp_cell.id = friend_name
        temp_cell.cell_type = "friend"
        temp_cell.name = friend_dic[friend_name]?["name"] as? String
        temp_cell.isRealPhoto = friend_dic[friend_name]?["isRealPhoto"] as? Bool
        temp_cell.online = friend_dic[friend_name]?["online"] as? Bool
        temp_cell.photoHttpStr = friend_dic[friend_name]?["photoHttpStr"] as? String
        temp_cell.sex = friend_dic[friend_name]?["sex"] as? String
        let lastLine = friend_dic[friend_name]?["lastLine"] as? String
        let last_speaker = friend_dic[friend_name]?["last_speaker"] as? String
        if last_speaker != "" && lastLine != ""{
            temp_cell.lastLine = "\(last_speaker!):\(lastLine!)"
        }
        
        return_list.append(temp_cell)
    }
    return return_list
}







