//
//  MyTopics.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/6/3.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class MyTopicTitle {
    var topicTitle:String
    var topics:Array<MyTopicDetail>
    var unRead:String{
        get{
            var unReadCount = 0
            for MyTopicDetail_s in topics{
                if MyTopicDetail_s.unRead == true{
                    unReadCount += 1
                }
            }
            return "未讀：\(unReadCount)/\(topics.count)"
        }
    }
    
    init(topicTitle:String, topics:Array<MyTopicDetail>){
        self.topicTitle = topicTitle
        self.topics = topics
    }

}


class MyTopicDetail {
    var clientId:String
    var clientName:String
    var clientPhoto: UIImage?
    var clientIsRealPhoto:Bool
    var clientSex:String
    var clientOnline:Bool
    var lastLine: String
    var lastSpeaker:String
    var unRead:Bool = false
    
    
    // MARK: Initialization
    
    init(clientId:String, clientName:String, clientPhoto: UIImage?, clientIsRealPhoto:Bool, clientSex:String, clientOnline:Bool, lastLine: String, lastSpeaker:String){
        
        self.clientId = clientId
        self.clientName = clientName
        self.clientPhoto = clientPhoto
        self.clientIsRealPhoto = clientIsRealPhoto
        self.clientSex  = clientSex
        self.clientOnline = clientOnline
        self.lastLine = lastLine
        self.lastSpeaker = lastSpeaker
        
    }
    
}


class MyRecentjoined {
    var owner: String
    var photo: UIImage?
    var title: String?
    var hashtags : [String]?
    var lastline : String
    var topicID : String
    
    
    // MARK: Initialization
    
    init?(owner: String, photo: UIImage, title: String, hashtags:[String], lastline: String, topicID:String){
        self.owner = owner
        self.photo = photo
        self.title = title
        self.hashtags = hashtags
        self.lastline = lastline
        self.topicID = topicID
        
        if owner.isEmpty || title.isEmpty {
            return nil
        }
    }
}