//
//  Topic.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class Topic {
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
    
    // MARK: Initialization
    
    init?(owner: String, photo: UIImage, title: String, hashtags:[String], lastline: String, topicID:String, sex:String, isMe:Bool, online:Bool, ownerName:String){
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
        
        if owner.isEmpty || title.isEmpty {
            return nil
        }
    }
}

