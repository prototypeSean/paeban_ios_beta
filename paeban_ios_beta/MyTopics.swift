//
//  MyTopics.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/6/3.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class MyTopic {
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