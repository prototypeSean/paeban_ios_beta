//
//  FriendStanderType.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

public class FriendStanderType{
    var id:String?
    var name:String?
    var sex:String?
    var isRealPhoto:Bool?
    var online:Bool?
    var photoHttpStr:String?
    var photo:UIImage?
}

public func turnToFriendStanderType(id:String,name:String,sex:String,isRealPhoto:Bool,online:Bool,photoString:String) ->FriendStanderType{
    let returnObj = FriendStanderType()
    returnObj.id = id
    returnObj.name = name
    returnObj.sex = sex
    returnObj.isRealPhoto = isRealPhoto
    returnObj.online = online
    returnObj.photoHttpStr = photoString
    let test = HttpRequestCenter()
    
    test.getHttpImg("http://www.paeban.com/media/\(photoString)") { (img) in
        returnObj.photo = img
        
    }
    return returnObj
}







