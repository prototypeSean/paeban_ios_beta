//
//  MyTopics.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/6/3.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

open class MyTopicStandardType {
    // === 公用類型資料變數 ===
    var dataType:String
    //title, detail
    var topicId_title:String?
    // === 公用類型資料變數 ===
    
    
    // === title類型資料變數 ===
    var topicTitle_title:String?
    var topicWithWhoDic_title:Dictionary<String,Bool>?
    var unReadMsg_title:Int{
        get{
            var unReadCount = 0
            for topicWithWho in topicWithWhoDic_title!{
                if topicWithWho.1 == false{
                    unReadCount += 1
                }
            }
            return unReadCount
        }
    }
    var allMsg_title:Int{
        get{return topicWithWhoDic_title!.count}
    }
    var battery:Int?
    // === title類型資料變數 ===
    
    
    // === detail類型資料變數 ===
    var clientId_detial:String?
    var clientName_detial:String?
    var clientPhoto_detial: UIImage?
    var clientIsRealPhoto_detial:Bool?
    var clientSex_detial:String?
    var clientOnline_detial:Bool?
    var lastLine_detial: String?
    var lastSpeaker_detial:String?
    var lastSpeaker_id_detial:String?
    var topicContentId_detial:String?
    var read_detial:Bool?
    var tag_detial:Array<String>?
    var time:TimeInterval?
    var level:Int?
    // === detail類型資料變數 ===
    
    var speak_time:timeval?
    init(dataType:String){
        // title  or  detial
        self.dataType = dataType
    }
}


//class MyTopicDetail {
//    var clientId:String
//    var clientName:String
//    var clientPhoto: UIImage?
//    var clientIsRealPhoto:Bool
//    var clientSex:String
//    var clientOnline:Bool
//    var lastLine: String
//    var lastSpeaker:String
//    var read:Bool = false
//    
//    
//    // MARK: Initialization
//    
//    init(clientId:String, clientName:String, clientPhoto: UIImage?, clientIsRealPhoto:Bool, clientSex:String, clientOnline:Bool, lastLine: String, lastSpeaker:String, read:Bool){
//        
//        self.clientId = clientId
//        self.clientName = clientName
//        self.clientPhoto = clientPhoto
//        self.clientIsRealPhoto = clientIsRealPhoto
//        self.clientSex  = clientSex
//        self.clientOnline = clientOnline
//        self.lastLine = lastLine
//        self.lastSpeaker = lastSpeaker
//        self.read = read
//        
//    }
//    
//}


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
