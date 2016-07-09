//
//  topicSecTableView.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/7/9.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class topicSecTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    
    var topics:Array<MyTopicDetail>?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("xxxx")
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "TopicSecTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! TopicSecTableViewCell
        
        let topic = topics![indexPath.row]
        print("xxxx")
        cell.clientName.text = topic.clientName
        
        
        return cell
    }
    
}
