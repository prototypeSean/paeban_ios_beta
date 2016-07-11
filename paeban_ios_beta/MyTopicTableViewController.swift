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
    let heightOfCell:CGFloat = 80
    var heightOfSecCell:CGFloat = 100
    var selectItemId:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMyTopic()
    }
    
    
    
    
    func getMyTopic() {
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
            let httpObj = ＨttpRequsetCenter()
            httpObj.requestMyTopic { (returnData) in
                dispatch_async(dispatch_get_main_queue(), {
                    //print(returnData)
                    self.mytopic = self.transferToStandardType(returnData)
                    for c in self.mytopic{
                        for cc in c.topics{
                            print(cc.clientId)
                        }
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func transferToStandardType(inputData:Dictionary<String,AnyObject>) -> Array<MyTopicTitle>{
        let topicDic:Dictionary<String,AnyObject> = inputData["topic_dic"] as! Dictionary
        var tempTopicList:Array<MyTopicTitle> = []
        
        for topicid in topicDic {
            //print(topicid)
            let topicContents = topicid.1["topic_contents"]
            
            var tempDetailList:Array<MyTopicDetail> = []
            for topicWithWho in topicContents as! Dictionary<String,AnyObject>{
                let imgString = topicWithWho.1["img"] as! String
                
                
                let clientId:String = topicWithWho.0
                let clientName:String = topicWithWho.1["topic_with_who_name"] as! String
                let clientPhoto: UIImage? = base64ToImage(imgString)
                let clientIsRealPhoto:Bool = topicWithWho.1["is_real_pic"] as! Bool
                let clientSex:String = topicWithWho.1["sex"] as! String
                let clientOnline:Bool = topicWithWho.1["online"] as! Bool
                let lastLine: String = topicWithWho.1["topic_content"] as! String
                let lastSpeaker:String = topicWithWho.1["last_speaker_name"] as! String
                let read:Bool = topicWithWho.1["read"] as! Bool
                //待新增物件 對方的名字 照片(有了還沒轉換) 已讀狀態
                
                let tempTopicDetail = MyTopicDetail(clientId: clientId, clientName: clientName, clientPhoto: clientPhoto, clientIsRealPhoto: clientIsRealPhoto, clientSex: clientSex, clientOnline: clientOnline, lastLine: lastLine, lastSpeaker: lastSpeaker, read:read)
                
                tempDetailList += [tempTopicDetail]
                
                
            }
            
            let topicConfig = topicid.1["topic_config"] as! Dictionary<String,String>
            let topicTitle = topicConfig["topic_title"]
            let topicUnit = MyTopicTitle(topicTitle: topicTitle!, topics: tempDetailList, topicId:topicid.0)
            tempTopicList += [topicUnit]
        }
        return tempTopicList
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {return 1}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return mytopic.count}
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        let topic = mytopic[indexPath.row]
        //let height2 = Int(heightOfCell) + (Int(heightOfSecCell) * topic.topics.count)
        if selectItemId != nil{
            if topic.topicId == selectItemId{
                let heightOfSecCellInt = Int(heightOfSecCell)
                let height = Int(heightOfCell) + (heightOfSecCellInt * topic.topics.count)
                return CGFloat(height)
            }
            else{
                return heightOfCell
            }
        }
        else{
            return heightOfCell
        }
        
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectPosition:Int = indexPath.row
        if selectItemId == nil{
            selectItemId = mytopic[selectPosition].topicId
        }
        else{
            if selectItemId != mytopic[selectPosition].topicId{
                selectItemId = mytopic[selectPosition].topicId
            }
            else{
                selectItemId = nil
            }
        }
        print(selectPosition)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "myTopicCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! MyTopicTableViewCell
        //cell.didLoad()
        let topic = mytopic[indexPath.row]
        cell.topicTitle.text = topic.topicTitle
        cell.unReadM.text = "/\(topic.unReadM)"
        cell.unReadS.text = "\(topic.unReadS)"
        print(topic.topicTitle)
        cell.dataList = topic.topics
        cell.setDelegate()
        cell.heightOfCell = heightOfSecCell
        cell.reloadCell()
        
        //cell.setDelegate()
        return cell
    }

}







