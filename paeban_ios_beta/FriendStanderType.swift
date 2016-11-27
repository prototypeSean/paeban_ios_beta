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







