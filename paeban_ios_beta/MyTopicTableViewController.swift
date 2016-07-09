//
//  MyTopicTableViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

// 我的話題清單
class MyTopicTableViewController: UITableViewController {


    
    
    
    
    // MARK: Properties
    var mytopic:Array<MyTopicTitle> = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testData()
    }
    
    
    func testData(){
        let sss = MyTopicDetail(clientId: "aaasss", clientName: "Elijah", clientPhoto: nil, clientIsRealPhoto: true, clientSex: "難", clientOnline: true, lastLine: "nonono", lastSpeaker: "aaasss")
        let ss = [sss]
        let ssss = MyTopicTitle(topicTitle: "TTT", topics: ss)
        mytopic += [ssss]
        
        let aaa = MyTopicDetail(clientId: "aaasss", clientName: "DDD", clientPhoto: nil, clientIsRealPhoto: true, clientSex: "難", clientOnline: true, lastLine: "nonono", lastSpeaker: "aaasss")
        let aa = [aaa]
        let aaaa = MyTopicTitle(topicTitle: "XXX", topics: aa)
        mytopic += [aaaa]
        
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {return 1}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return mytopic.count}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "myTopicCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! MyTopicTableViewCell
        
        let topic = mytopic[indexPath.row]
        cell.topicTitle.text = topic.topicTitle
        cell.unRead.text = topic.unRead
        
        
        
        
        let secViewForCell = topicSecTableView()
        secViewForCell.topics = topic.topics
        cell.topicTableDetail = secViewForCell
        
        
//        cell.repliedContent.text = topic.title
//        cell.repliedImage.image = topic.photo

        return cell
    }
    
    
    
}
