//
//  TopicDataType.swift
//  paeban_ios_beta
//
//  Created by elijah on 2018/3/8.
//  Copyright © 2018年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

// 重構 2018.3.8
class TopicData{
    var owner: String
    var photo: UIImage?
    var title: String?
    var hashtags : [String]?
    var lastline : String
    var topicID : String
    var sex:String
    var isMe:Bool
    var online:Bool
    var ownerName:String
    var is_friend:Bool?
    var battery: Int?
    var distance:String?
    
    init?(owner: String, photo: UIImage, title: String, hashtags:[String], lastline: String, topicID:String, sex:String, isMe:Bool, online:Bool, ownerName:String, battery: Int){
        self.owner = owner
        self.photo = photo
        self.title = title
        self.hashtags = hashtags
        self.lastline = lastline
        self.sex = sex
        self.isMe = isMe
        self.online = online
        self.topicID = topicID
        self.ownerName = ownerName
        self.battery = battery
        
        if owner.isEmpty || title.isEmpty {
            return nil
        }
    }
}
