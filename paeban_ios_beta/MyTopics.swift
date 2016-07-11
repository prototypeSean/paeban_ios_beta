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
    var topicId:String
    var unReadS:Int{
        get{
            var unReadCount = 0
            for MyTopicDetail_s in topics{
                if MyTopicDetail_s.read == false{
                    unReadCount += 1
                }
            }
            return unReadCount
        }
    }
    var unReadM:Int{
        get{return topics.count}
    }
    init(topicTitle:String, topics:Array<MyTopicDetail>, topicId:String){
        self.topicTitle = topicTitle
        self.topics = topics
        self.topicId = topicId
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
    var read:Bool = false
    
    
    // MARK: Initialization
    
    init(clientId:String, clientName:String, clientPhoto: UIImage?, clientIsRealPhoto:Bool, clientSex:String, clientOnline:Bool, lastLine: String, lastSpeaker:String, read:Bool){
        
        self.clientId = clientId
        self.clientName = clientName
        self.clientPhoto = clientPhoto
        self.clientIsRealPhoto = clientIsRealPhoto
        self.clientSex  = clientSex
        self.clientOnline = clientOnline
        self.lastLine = lastLine
        self.lastSpeaker = lastSpeaker
        self.read = read
        
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