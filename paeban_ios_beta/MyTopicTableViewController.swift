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
    var mytopic:Array<MyTopicStandardType> = []
    let heightOfCell:CGFloat = 85
    var heightOfSecCell:CGFloat = 130
    var selectItemId:String?
    var switchFirst = true
    override func viewDidLoad() {
        super.viewDidLoad()
        get_my_topic_title()
    }
    
    
    
    
    func get_my_topic_title() {
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
            let httpObj = ＨttpRequsetCenter()
            httpObj.get_my_topic_title { (returnData) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.mytopic = self.transferToStandardType_title(returnData)

                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func transferToStandardType_title(inputData:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>{
        // return_dic = topic_id* -- topic_title : String
        //                        -- topic_with_who_id* -- read:Bool
        var tempMytopicList = [MyTopicStandardType]()
        for topic_id in inputData{
            let topicTitleData = MyTopicStandardType(dataType:"title")
            let topicTitle = (topic_id.1 as! Dictionary<String,AnyObject>)["topic_title"] as! String
            let topicId = topic_id.0
            var topicWithWhoDic: Dictionary<String,Bool> = [:]
            for topic_with_who_id in (topic_id.1 as! Dictionary<String,AnyObject>){
                let read = (topic_with_who_id.1 as! Dictionary<String,Bool>)["read"]
                topicWithWhoDic[topic_with_who_id.0] = read
            }
            topicTitleData.topicTitle_title = topicTitle
            topicTitleData.topicId_title = topicId
            topicTitleData.topicWithWhoDic_title = topicWithWhoDic
            tempMytopicList += [topicTitleData]
        }
        
        return tempMytopicList
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {return 1}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return mytopic.count}
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // code
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let topicWriteToRow = mytopic[indexPath.row]
        if topicWriteToRow.dataType == "title"{
            // 標題型cell
            let cell = tableView.dequeueReusableCellWithIdentifier("myTopicCell_1", forIndexPath: indexPath) as! MyTopicTableViewCell
            cell.topicTitle.text = topicWriteToRow.topicTitle_title
            cell.unReadM.text = String(topicWriteToRow.allMsg_title)
            cell.unReadS.text = String(topicWriteToRow.unReadMsg_title)
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("myTopicCell_2", forIndexPath: indexPath) as! TopicSecTableViewCell
            cell.clientName.text = topicWriteToRow.clientName_detial
            cell.speaker.text = topicWriteToRow.lastSpeaker_detial
            cell.lastLine.text = topicWriteToRow.lastLine_detial
            cell.photo.image = topicWriteToRow.clientPhoto_detial
            if topicWriteToRow.clientPhoto_detial! == true{
                
            }
            else{
            
            }
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.identifier)
    }

}







