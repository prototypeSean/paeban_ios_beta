//
//  MyTopicTableViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

// 我的話題清單
class MyTopicTableViewController: UITableViewController,webSocketActiveCenterDelegate {


    // MARK: Properties
    var mytopic:Array<MyTopicStandardType> = []
    var secTopic:Dictionary<String,AnyObject> = [:]
    let heightOfCell:CGFloat = 85
    var heightOfSecCell:CGFloat = 130
    var selectItemId:String?
    var switchFirst = true
    var nowAcceptTopicId:String?
    var selectIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        get_my_topic_title()
        wsActive.wasd_ForMyTopicTableViewController = self
    }
    
    
    
    func wsOnMsg(msg:Dictionary<String,AnyObject>){
        // msg -- topic_msg:String
        //     -- img:Dtring
        //     -- result_dic --
        if msg["msg_type"] as! String == "topic_msg"{
            //code
            
        }
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
    
    func get_my_topic_detail(topicId:String){
        
        let qos = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
            let httpObj = ＨttpRequsetCenter()
            httpObj.get_my_topic_detail(topicId, InViewAct: { (returnData) in
                dispatch_async(dispatch_get_main_queue(), {
                    let topicId = returnData["topic_id"] as! String
                    self.secTopic[topicId] = returnData
                    print("第\(self.secTopic.count)筆詳細資料下載完畢")
                })
            })
        }
    }
    
    func transferToStandardType_title(inputData:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>{
        // return_dic = topic_id* -- topic_title : String
        //                        -- topics               -- topic_with_who_id* -- read:Bool
        var tempMytopicList = [MyTopicStandardType]()
        for topic_id in inputData{
            let topicTitleData = MyTopicStandardType(dataType:"title")
            let topicTitle = (topic_id.1 as! Dictionary<String,AnyObject>)["topic_title"] as! String
            let topicId = topic_id.0
            print("編號\(topicId)Topic標題下載完畢")
            get_my_topic_detail(topicId)
            var topicWithWhoDic: Dictionary<String,Bool> = [:]
            for topic_with_who_id in (topic_id.1 as! Dictionary<String,AnyObject>)["topics"] as! Dictionary<String,AnyObject>{
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
    
    func transferToStandardType_detail(inputData:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType> {
        // return_dic --topic_id:String
        //            --topic_contents  --topic_with_who_id* -- topic_with_who_name:String
        //                                     last_speaker:String
        //                                     ...
        var tempMytopicList = [MyTopicStandardType]()
        for topicWithWhoId in inputData["topic_contents"] as! Dictionary<String,Dictionary<String,AnyObject>>{
            let topicTitleData = MyTopicStandardType(dataType:"detail")
            topicTitleData.clientId_detial = topicWithWhoId.0
            topicTitleData.topicId_title = inputData["topic_id"] as? String
            topicTitleData.clientName_detial = topicWithWhoId.1["topic_with_who_name"] as? String
            let img = base64ToImage(topicWithWhoId.1["img"] as! String)
            topicTitleData.clientPhoto_detial = img
            topicTitleData.clientIsRealPhoto_detial = topicWithWhoId.1["is_real_pic"] as? Bool
            topicTitleData.clientSex_detial = topicWithWhoId.1["sex"] as? String
            topicTitleData.clientOnline_detial = topicWithWhoId.1["online"] as? Bool
            topicTitleData.lastLine_detial = topicWithWhoId.1["topic_content"] as? String
            topicTitleData.lastSpeaker_detial = topicWithWhoId.1["last_speaker_name"] as? String
            topicTitleData.read_detial = topicWithWhoId.1["read"] as? Bool
            tempMytopicList += [topicTitleData]
        }
        return tempMytopicList
    }
    func updateSelectIndex(topicId:String, anyFunction: () -> Void){
        anyFunction()
        let newCellIndex = mytopic.indexOf({ (MyTopicStandardTypeObj) -> Bool in
            if MyTopicStandardTypeObj.dataType == "title"{
                if MyTopicStandardTypeObj.topicId_title! == topicId{
                    return true
                }
                else{return false}
            }
            else{return false}
        })
        self.selectIndex = newCellIndex
    }
    
    
    func collectCell(){
        var removeList = [Int]()
        var removeNSIndexPathList = [NSIndexPath]()
        for cell_s_Index in 0..<mytopic.count{
            if mytopic[cell_s_Index].dataType == "detail"{
                removeList.insert(cell_s_Index, atIndex: 0)
                let removeNSIndexPath = NSIndexPath(forRow: cell_s_Index, inSection: 0)
                removeNSIndexPathList.insert(removeNSIndexPath, atIndex: 0)
            }
        }
        for removeIndex in removeList{
            mytopic.removeAtIndex(removeIndex)
        }
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths(removeNSIndexPathList, withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()
    }
    
    func getSecCellData(topicId:String,selectIndex:Int){
        let secCellDataIndex = secTopic.indexOf { (topicIdInIndex, _) -> Bool in
            if topicIdInIndex == topicId{
                return true
            }
            else{return false}
        }
        if secCellDataIndex == nil{
            //資料還沒進來
            waitSecTopicData(topicId, selectIndex: selectIndex)
        }
        else{
            //資料進來了
            insertSecCell(secTopic[topicId] as! Dictionary<String,AnyObject>, selectIndex: selectIndex)
        }
    }
    
    func insertSecCell(inputDic:Dictionary<String,AnyObject>, selectIndex:Int) {
        let insertDataList = transferToStandardType_detail(inputDic)
        var updataIndexList = [NSIndexPath]()
        var updataIndexInt = selectIndex
        for insertData in insertDataList{
            updataIndexInt += 1
            let updataIndex = NSIndexPath(forRow: updataIndexInt, inSection: 0)
            updataIndexList.append(updataIndex)
            mytopic.insert(insertData, atIndex: selectIndex + 1)
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(updataIndexList, withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()

    }
    
    // MARK:等待中
    func waitSecTopicData(topicId:String,selectIndex:Int) {
        
        var toExecution = true
        var AcceptThisClick = true
        if nowAcceptTopicId != nil {
            if nowAcceptTopicId == topicId{
                AcceptThisClick = false
            }
        }
        nowAcceptTopicId = topicId
        if AcceptThisClick{
            var willInsertLoad = true
            let qos = DISPATCH_QUEUE_PRIORITY_LOW
            dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
                var waitTime:Int = 5000
                //print(NSDate().timeIntervalSince1970)
                var sexDataIndex = self.secTopic.indexOf { (topicIdInIndex, _) -> Bool in
                    if topicIdInIndex == topicId{
                        return true
                    }
                    else{return false}
                }
                
                while waitTime >= 0 && sexDataIndex == nil {
                    // ===插入讀取cell畫面===
                    if self.mytopic.count-1 == selectIndex && willInsertLoad == true{
                        willInsertLoad = false
                        dispatch_async(dispatch_get_main_queue(), {
                            self.insertLoadingCell(selectIndex)
                        })
                    }
                    else if self.mytopic.count-1 > selectIndex && willInsertLoad == true{
                        if self.mytopic[selectIndex+1].dataType != "reloading"{
                            willInsertLoad = false
                            dispatch_async(dispatch_get_main_queue(), {
                                self.insertLoadingCell(selectIndex)
                            })
                        }
                    }
                    // ===插入讀取cell畫面===
                    
                    usleep(10000)
                    
                    //1ms = 1000us
                    if self.nowAcceptTopicId != nil{
                        if self.nowAcceptTopicId! != topicId{
                            toExecution = false
                            break
                        }
                    }
                    sexDataIndex = self.secTopic.indexOf { (topicIdInIndex, _) -> Bool in
                        if topicIdInIndex == topicId{
                            return true
                        }
                        else{return false}
                    }
                    waitTime -= 10
                }
                if toExecution{
                    if sexDataIndex != nil{
                        //資料進來了
                        dispatch_async(dispatch_get_main_queue(), {
                            self.updateSelectIndex(topicId, anyFunction: {
                                self.removeLoadingCell()
                            })
                            self.insertSecCell(self.secTopic[topicId] as! Dictionary<String,AnyObject>, selectIndex: selectIndex)
                        })
                    }
                    else{
                        print("timeOut")
                        //print(NSDate().timeIntervalSince1970)
                        // 顯示手動更新按鈕
                    }
                }
            }
        }
        
    }
    
    func insertLoadingCell(selectIndex:Int) {
        let insertObj = MyTopicStandardType(dataType: "reloading")
        mytopic.insert(insertObj, atIndex: selectIndex+1)
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: selectIndex+1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()
    }
    
    func removeLoadingCell() {
        var removeTopicObjIndexList = [Int]()
        var removeNSIndexPachList = [NSIndexPath]()
        for topicObj_s in 0..<mytopic.count{
            if mytopic[topicObj_s].dataType == "reloading"{
                removeTopicObjIndexList.insert(topicObj_s, atIndex: 0)
                let removeNSIndexPach = NSIndexPath(forRow: topicObj_s, inSection: 0)
                removeNSIndexPachList.insert(removeNSIndexPach, atIndex: 0)
            }
        }
        for removeTopicObjIndex in removeTopicObjIndexList{
            mytopic.removeAtIndex(removeTopicObjIndex)
        }
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths(removeNSIndexPachList, withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
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
        else if topicWriteToRow.dataType == "detail"{
            // 子對話型cell
            let cell = tableView.dequeueReusableCellWithIdentifier("myTopicCell_2", forIndexPath: indexPath) as! TopicSecTableViewCell
            cell.clientName.text = topicWriteToRow.clientName_detial
            cell.speaker.text = topicWriteToRow.lastSpeaker_detial
            cell.lastLine.text = topicWriteToRow.lastLine_detial
            cell.photo.image = topicWriteToRow.clientPhoto_detial
            cell.sexLogo.image = letoutSexLogo(topicWriteToRow.clientSex_detial!)
            cell.isTruePhoto.image = letoutIsTruePhoto(topicWriteToRow.clientIsRealPhoto_detial!)
            letoutOnlineLogo(topicWriteToRow.clientOnline_detial!,cellOnlineLogo: cell.onlineLogo)
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell", forIndexPath: indexPath) as! TableViewLoadingCell
            // MARK:調整刷新圖示的地方
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: cell.frame.maxX, height: 70)
            //activityIndicator.center = cell.center
            activityIndicator.transform = CGAffineTransformMakeScale(1.3, 1.3)
            activityIndicator.startAnimating()
            cell.addSubview(activityIndicator)
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.identifier)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {return 1}
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return mytopic.count}
    
    // MARK: 選擇cell後
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellIndex = indexPath.row
        var actMode = false
        if mytopic[cellIndex].dataType == "title"{
            if cellIndex == mytopic.count-1{
                actMode = true
            }
            else if mytopic[cellIndex + 1].dataType != "detail"{
                actMode = true
            }
            if actMode{
                // 伸展子cell
                
                let topicId_title = mytopic[cellIndex].topicId_title
                
                updateSelectIndex(topicId_title!, anyFunction: {
                    self.removeLoadingCell()
                    self.collectCell()
                })
                
                
                getSecCellData(mytopic[self.selectIndex!].topicId_title!,selectIndex: Int(self.selectIndex!))
            }
            else{
                //縮回子cell
                if let topicId_title = mytopic[cellIndex].topicId_title{
                    updateSelectIndex(topicId_title, anyFunction: {
                        self.removeLoadingCell()
                    })
                }
                
                
                let dataLen = mytopic.count
                var removeRowList = [NSIndexPath]()
                var removeIndexList = [Int]()
                for removeIndex in (selectIndex!+1)..<dataLen{
                    if mytopic[removeIndex].dataType == "detail"{
                        removeIndexList.insert(removeIndex, atIndex: 0)
                        let removeRow = NSIndexPath(forRow: removeIndex, inSection: 0)
                        removeRowList += [removeRow]
                    }
                    else{
                        break
                    }
                }
                for removeIndex in removeIndexList{
                    mytopic.removeAtIndex(removeIndex)
                }
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths(removeRowList, withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.endUpdates()
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        
        
    }
    
    func letoutSexLogo(sex:String) -> UIImage {
        var sexImg:UIImage
        switch sex {
        case "男":
            sexImg = UIImage(named: "male")!
        case "女":
            sexImg = UIImage(named:"gay")!
        case "男同":
            sexImg = UIImage(named:"gay")!
        case "女同":
            sexImg = UIImage(named:"lesbain")!
        default:
            sexImg = UIImage(named: "male")!
            print("性別圖示分類失敗")
        }
        return sexImg
    }
    func letoutIsTruePhoto(isTruePhoto:Bool) -> UIImage {
        var isMeImg:UIImage
        if isTruePhoto{isMeImg = UIImage(named:"True_photo")!}
        else{isMeImg = UIImage(named:"Fake_photo")!}
        return isMeImg
    }
    func letoutOnlineLogo(isOnline:Bool,cellOnlineLogo:UIImageView){
        
        cellOnlineLogo.image = UIImage(named:"texting")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        if isOnline{
            cellOnlineLogo.tintColor = UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
        }
        else{
            cellOnlineLogo.tintColor = UIColor.grayColor()
        }
    }
}

