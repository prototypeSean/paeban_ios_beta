//
//  MyTopicTableViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

// 我的話題清單
class MyTopicTableViewController: UITableViewController,webSocketActiveCenterDelegate,webSocketActiveCenterDelegate_re {


    // MARK: Properties
    var mytopic:Array<MyTopicStandardType> = []
    var secTopic:Dictionary = [String: [MyTopicStandardType]]()
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
        wsActive.ware_ForMyTopicTableViewController = self
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: 父CELL漸層
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cellIndex = (indexPath as NSIndexPath).row
//        if mytopic[cellIndex].dataType == "title"{
//            let gradientBackgroundColors = [UIColor(red:0.97, green:0.97, blue:0.96, alpha:1.0).cgColor, UIColor.white.cgColor,UIColor(red:0.97, green:0.97, blue:0.96, alpha:1.0).cgColor]
//            let gradientLocations = [0.0,1.0,0.0]
//            
//            let gradientLayer = CAGradientLayer()
//            gradientLayer.colors = gradientBackgroundColors
//            gradientLayer.locations = gradientLocations as [NSNumber]?
//            
//            gradientLayer.frame = cell.bounds
//            let backgroundView = UIView(frame: cell.bounds)
//            backgroundView.layer.insertSublayer(gradientLayer, at: 0)
//            
//            cell.backgroundView = backgroundView
//        }
    }

    
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        if msg["msg_type"] as! String == "topic_msg"{
            updataSecTopic(msg)
        }
    }
    
    func updataSecTopic(_ msg:Dictionary<String,AnyObject>){
        // msg -- msg_type:"topic_msg"
        //     -- img:String
        //     -- result_dic --topic_content_id* -- sender:String
        //                                       -- temp_topic_msg_id
        //                                       -- topic_content
        //                                       -- receiver
        //                                       -- topic_id
        //print(msg)
        let result_dic = msg["result_dic"] as! Dictionary<String,Dictionary<String,String>>
        for topic_content_id in result_dic{
            let topic_content_data = topic_content_id.1
            let topic_id = topic_content_data["topic_id"]!
            let secTopicIndex = secTopic.index(where: { (key, _) -> Bool in
                if key == topic_id{
                    return true
                }
                else{return false}
            })
            if secTopicIndex != nil{
                var topicWithWho:String
                if userData.id == topic_content_data["sender"]{
                    topicWithWho = topic_content_data["receiver"]!
                }
                else{
                    topicWithWho = topic_content_data["sender"]!
                }
                let localTopicData = secTopic[topic_id]!
                let localTopicDataIndex = localTopicData.index(where: { (MyTopicStandardType) -> Bool in
                    if MyTopicStandardType.clientId_detial == topicWithWho{
                        return true
                    }
                    else{return false}
                })
                if localTopicDataIndex == nil{
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                            let httpObj = HttpRequestCenter()
                            // MARK:補設計timeout功能
                            httpObj.request_topic_msg_config(topic_id, client_id: topicWithWho, topic_content_id: topic_content_id.0){ (returnData) in
                                if returnData["topic_content_id"] as! String == topic_content_id.0{
                                    let returnDic = returnData
                                    
                                    let newTopicDetailObj = MyTopicStandardType(dataType: "detail")
                                    let imgStr = returnDic["img"] as! String
                                    let img = base64ToImage(imgStr)
                                    
                                    newTopicDetailObj.clientId_detial = topicWithWho
                                    newTopicDetailObj.clientName_detial = returnDic["client_name"] as? String
                                    newTopicDetailObj.clientPhoto_detial = img
                                    newTopicDetailObj.clientIsRealPhoto_detial = returnDic["client_is_real_photo"] as? Bool
                                    newTopicDetailObj.clientSex_detial = returnDic["client_sex"] as? String
                                    newTopicDetailObj.clientOnline_detial = returnDic["client_online"] as? Bool
                                    newTopicDetailObj.lastLine_detial = topic_content_data["topic_content"]
                                    newTopicDetailObj.lastSpeaker_detial = topic_content_data["sender"]!
                                    newTopicDetailObj.read_detial = false
                                    newTopicDetailObj.topicId_title = topic_id
                                    newTopicDetailObj.topicContentId_detial = topic_content_id.0
                                    self.updataTitleCellList_isRead(topic_id, topicWithWho: topicWithWho, read: false)
                                    DispatchQueue.main.async(execute: {
                                        self.secTopic[topic_id]! += [newTopicDetailObj]
                                        var checkTopicsIndex = 0
                                        for checkTopics in self.mytopic{
                                            if checkTopics.dataType != "title"{
                                                self.mytopic.insert(newTopicDetailObj, at: checkTopicsIndex)
                                                let tempIndexPath = IndexPath(row: checkTopicsIndex, section: 0)
                                                self.tableView.beginUpdates()
                                                self.tableView.insertRows(at: [tempIndexPath], with: UITableViewRowAnimation.automatic)
                                                self.tableView.endUpdates()
                                            }
                                            checkTopicsIndex += 1
                                        }
                                        
                                        self.updataTitleUnread(topic_id)
                                        self.tableView.reloadData()
                                    })
                                }
                                
                            }
                    }
                }
                else{
                    //更新現有資料
                    let localData = localTopicData[Int(localTopicDataIndex!)]
                    if topic_content_data["sender"] == userData.id{
                        localData.lastSpeaker_detial = userData.name
                    }
                    else{
                        localData.lastSpeaker_detial = localData.clientName_detial
                    }
                    localData.lastLine_detial = topic_content_data["topic_content"]
                    let uiDataIndex = mytopic.index(where: { (MyTopicStandardType) -> Bool in
                        if MyTopicStandardType.topicId_title == topic_id
                            && MyTopicStandardType.clientId_detial == topicWithWho{
                            return true
                        }
                        else{return false}
                    })
                    if uiDataIndex != nil{
                        mytopic.remove(at: Int(uiDataIndex!))
                        mytopic.insert(localData, at: uiDataIndex!)
                        self.updataTitleUnread(localData.topicId_title!)
                        self.tableView.reloadData()
                    }
                }
            }
            else{
                //沒有這條topice,所以是另一邊的tableView要更新
            }
        }
        
        
    }
    
    func updataTitleUnread(_ topicId:String){
        let tagretIndex = self.mytopic.index { (obj_s) -> Bool in
            if obj_s.dataType == "title" && obj_s.topicId_title! == topicId{
                return true
            }
            else{return false}
        }
        if tagretIndex != nil{
            var newUnreadDic: Dictionary<String,Bool> = [:]
            if let secCellList = secTopic[topicId]{
                for c in secCellList{
                    newUnreadDic[c.clientId_detial!] = c.read_detial!
                }
                mytopic[tagretIndex!].topicWithWhoDic_title = newUnreadDic
            }
        }
    }
    
    func get_my_topic_title() {
        DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async{ () -> Void in
            let httpObj = HttpRequestCenter()
            httpObj.get_my_topic_title { (returnData) in
                DispatchQueue.main.async(execute: {
                    self.mytopic = self.transferToStandardType_title(returnData)
                    print(returnData)
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func get_my_topic_detail(_ topicId:String){
        
        DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async{ () -> Void in
            let httpObj = HttpRequestCenter()
            httpObj.get_my_topic_detail(topicId, InViewAct: { (returnData) in
                DispatchQueue.main.async(execute: {
                    let topicId = returnData["topic_id"] as! String
                    let returnDataList = self.transferToStandardType_detail(returnData)
                    self.secTopic[topicId] = returnDataList
                    
                    
                    print("第\(self.secTopic.count)筆詳細資料下載完畢")
                    
                })
            })
        }
    }
    
    func transferToStandardType_title(_ inputData:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>{
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
    
    func transferToStandardType_detail(_ inputData:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType> {
        // return_dic --topic_id:String
        //            --topic_contents-topic_with_who_id*- topic_with_who_name:String
        //                                               - last_speaker:String
        //                                               - img
        //                                               - is_real_pic
        //                                               - sex
        //                                               - online
        //                                               - topic_content
        //                                               - last_speaker_name
        //                                               - read
        //                                               - topic_content_id
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
            topicTitleData.topicContentId_detial = String(topicWithWhoId.1["topic_content_id"] as! Int)
            
            tempMytopicList += [topicTitleData]
        }
        return tempMytopicList
    }
    func updateSelectIndex(_ topicId:String, anyFunction: () -> Void){
        anyFunction()
        let newCellIndex = mytopic.index(where: { (MyTopicStandardTypeObj) -> Bool in
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
        var removeNSIndexPathList = [IndexPath]()
        for cell_s_Index in 0..<mytopic.count{
            if mytopic[cell_s_Index].dataType == "detail"{
                removeList.insert(cell_s_Index, at: 0)
                let removeNSIndexPath = IndexPath(row: cell_s_Index, section: 0)
                removeNSIndexPathList.insert(removeNSIndexPath, at: 0)
            }
        }
        for removeIndex in removeList{
            mytopic.remove(at: removeIndex)
        }
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: removeNSIndexPathList, with: UITableViewRowAnimation.automatic)
        self.tableView.endUpdates()
    }
    
    func getSecCellData(_ topicId:String,selectIndex:Int){
        let secCellDataIndex = secTopic.index { (topicIdInIndex, _) -> Bool in
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
            insertSecCell(secTopic[topicId]! as Array<MyTopicStandardType>, selectIndex: selectIndex)
        }
    }
    
    func insertSecCell(_ inputList:[MyTopicStandardType], selectIndex:Int) {
        
        var updataIndexList = [IndexPath]()
        var updataIndexInt = selectIndex
        for insertData in inputList{
            updataIndexInt += 1
            let updataIndex = IndexPath(row: updataIndexInt, section: 0)
            updataIndexList.append(updataIndex)
            mytopic.insert(insertData, at: selectIndex + 1)
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: updataIndexList, with: UITableViewRowAnimation.automatic)
        self.tableView.endUpdates()

    }
    
    // MARK:等待中
    func waitSecTopicData(_ topicId:String,selectIndex:Int) {
        
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
            DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async{ () -> Void in
                var waitTime:Int = 15000
                var dataNumber = -1
                var totalDataNember = 0
                // 查詢資料庫有無資料
                let titleIndex = self.mytopic.index(where: { (target) -> Bool in
                    if target.topicId_title == topicId{
                        return true
                    }
                    else{return false}
                })
                if titleIndex != nil{
                    totalDataNember = self.mytopic[titleIndex! as Int].allMsg_title
                }
                if self.secTopic[topicId] != nil{
                    dataNumber = self.secTopic[topicId]!.count
                }
                
//                var sexDataIndex = self.secTopic.indexOf { (topicIdInIndex, _) -> Bool in
//                    if topicIdInIndex == topicId{
//                        return true
//                    }
//                    else{return false}
//                }
                
                while waitTime >= 0 && dataNumber < totalDataNember {
                    // ===插入讀取cell畫面===
                    if self.mytopic.count-1 == selectIndex && willInsertLoad == true{
                        willInsertLoad = false
                        DispatchQueue.main.async(execute: {
                            self.insertLoadingCell(selectIndex)
                        })
                    }
                    else if self.mytopic.count-1 > selectIndex && willInsertLoad == true{
                        if self.mytopic[selectIndex+1].dataType != "reloading"{
                            willInsertLoad = false
                            DispatchQueue.main.async(execute: {
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
                    if self.secTopic[topicId] != nil{
                        dataNumber = self.secTopic[topicId]!.count
                    }
                    waitTime -= 10
                }
                if toExecution{
                    if dataNumber == totalDataNember{
                        //資料進來了
                        DispatchQueue.main.async(execute: {
                            self.updateSelectIndex(topicId, anyFunction: {
                                self.removeLoadingCell()
                            })
                            self.insertSecCell(self.secTopic[topicId]! as Array<MyTopicStandardType>, selectIndex: selectIndex)
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
    
    func updataTitleCellList_isRead(_ topicId:String,topicWithWho:String,read:Bool){
        let titleIndex = mytopic.index { (MyTopicStandardType) -> Bool in
            if MyTopicStandardType.topicId_title == topicId{
                return true
            }
            else{return false}
        }
        if titleIndex != nil{
            mytopic[titleIndex!].topicWithWhoDic_title!["topicWithWho"] = read
        }
    }
    
    
    func insertLoadingCell(_ selectIndex:Int) {
        let insertObj = MyTopicStandardType(dataType: "reloading")
        mytopic.insert(insertObj, at: selectIndex+1)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: selectIndex+1, section: 0)], with: UITableViewRowAnimation.automatic)
        self.tableView.endUpdates()
    }
    
    func removeLoadingCell() {
        var removeTopicObjIndexList = [Int]()
        var removeNSIndexPachList = [IndexPath]()
        for topicObj_s in 0..<mytopic.count{
            if mytopic[topicObj_s].dataType == "reloading"{
                removeTopicObjIndexList.insert(topicObj_s, at: 0)
                let removeNSIndexPach = IndexPath(row: topicObj_s, section: 0)
                removeNSIndexPachList.insert(removeNSIndexPach, at: 0)
            }
        }
        for removeTopicObjIndex in removeTopicObjIndexList{
            mytopic.remove(at: removeTopicObjIndex)
        }
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: removeNSIndexPachList, with: UITableViewRowAnimation.automatic)
        self.tableView.endUpdates()
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topicWriteToRow = mytopic[(indexPath as NSIndexPath).row]
        if topicWriteToRow.dataType == "title"{
            // 父cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "myTopicCell_1", for: indexPath) as! MyTopicTableViewCell
            cell.topicTitle.text = topicWriteToRow.topicTitle_title
            cell.unReadM.text = "/"+String(topicWriteToRow.allMsg_title)
            cell.unReadS.text = String(topicWriteToRow.unReadMsg_title)
            
            // 給ET：之後要加入電池的選項CASE對應參數
            letoutBattery(battery: cell.myTopicbattery)
            
            // Hashtag 沒有作用不知道位啥
            print(topicWriteToRow.tag_detial)
            //cell.myTopicHashtag.tagListInContorller = topicWriteToRow.tag_detial
            //cell.myTopicHashtag.drawButton()
            return cell
        }
        else if topicWriteToRow.dataType == "detail"{
            // 子cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "myTopicCell_2", for: indexPath) as! TopicSecTableViewCell
            cell.clientName.text = topicWriteToRow.clientName_detial
            cell.speaker.text = topicWriteToRow.lastSpeaker_detial
            cell.lastLine.text = topicWriteToRow.lastLine_detial
            cell.photo.image = topicWriteToRow.clientPhoto_detial
            cell.sexLogo.image = letoutSexLogo(topicWriteToRow.clientSex_detial!)
            
            letoutOnlineLogo(topicWriteToRow.clientOnline_detial!,cellOnlineLogo: cell.onlineLogo)
            letoutIsTruePhoto(topicWriteToRow.clientIsRealPhoto_detial!,isMeImg: cell.isTruePhoto)
            
            // MARK: 切子cell照片圓角
            let myPhotoLayer:CALayer = cell.photo.layer
            myPhotoLayer.masksToBounds = true
            myPhotoLayer.cornerRadius = 6
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! TableViewLoadingCell
            // MARK:調整刷新圖示的地方
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: cell.frame.maxX, height: 70)
            //activityIndicator.center = cell.center
            activityIndicator.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            activityIndicator.startAnimating()
            cell.addSubview(activityIndicator)
            
            return cell
        }
    }
    // 畫面轉跳
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "masterModeSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow!
            let dataposition:Int = (indexPath as NSIndexPath).row
            let nextView = segue.destination as! MyTopicViewController
            let data = mytopic[dataposition]
            nextView.setID = data.clientId_detial
            nextView.setName = data.clientName_detial
            nextView.topicId = data.topicId_title
            nextView.clientImg = data.clientPhoto_detial
            nextView.topicTitle = data.topicTitle_title
            nextView.title = data.clientName_detial
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return mytopic.count}
    
    // MARK: 選擇cell後
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellIndex = (indexPath as NSIndexPath).row
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
                var removeRowList = [IndexPath]()
                var removeIndexList = [Int]()
                for removeIndex in (selectIndex!+1)..<dataLen{
                    if mytopic[removeIndex].dataType == "detail"{
                        removeIndexList.insert(removeIndex, at: 0)
                        let removeRow = IndexPath(row: removeIndex, section: 0)
                        removeRowList += [removeRow]
                    }
                    else{
                        break
                    }
                }
                for removeIndex in removeIndexList{
                    mytopic.remove(at: removeIndex)
                }
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: removeRowList, with: UITableViewRowAnimation.automatic)
                self.tableView.endUpdates()
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    // MARK: 設定cell 裡面的圖示

    //之後要加入電池的選項CASE
    func letoutBattery(battery:UIImageView){
        battery.image = UIImage(named:"battery-low")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        battery.tintColor = UIColor.red
    }
    
    
    func letoutSexLogo(_ sex:String) -> UIImage {
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
    func letoutIsTruePhoto(_ isTruePhoto:Bool,isMeImg:UIImageView){
        isMeImg.image = UIImage(named:"True_photo")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        if isTruePhoto{
            isMeImg.tintColor = UIColor.white
        }
        else{
            isMeImg.tintColor = UIColor.clear
        }
    }
    func letoutOnlineLogo(_ isOnline:Bool,cellOnlineLogo:UIImageView){
        
        cellOnlineLogo.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        if isOnline{
            cellOnlineLogo.tintColor = UIColor(red:0.15, green:0.88, blue:0.77, alpha:1.0)
        }
        else{
            cellOnlineLogo.tintColor = UIColor.lightGray
        }
    }
    
    func wsReconnected(){
        //dic -- title* -- detail* --
        checkData()
    }
    
    func checkData(){
        // dic - topicId* - topicWithWho* - topicContentId
        var ckeckDic:Dictionary<String,Dictionary<String,String>>
        ckeckDic = [:]
        
        for topicDatas in secTopic{
            ckeckDic[topicDatas.0] = [:]
            for secTopicDatas in topicDatas.1{
                ckeckDic[topicDatas.0]![secTopicDatas.clientId_detial!] = secTopicDatas.topicContentId_detial!
            }
        }
        
        
        // 檢查是否有完全沒資料的的topic_id
        for cellsData in mytopic{
            if cellsData.dataType == "title"{
                let check_topic_id = ckeckDic[cellsData.topicId_title!]
                if check_topic_id == nil{
                    ckeckDic[cellsData.topicId_title!] = [:]
                }
            }
        }
        
        let sendDic = ckeckDic as Dictionary<String,Dictionary<String,String>> as NSDictionary
        let httpObj = HttpRequestCenter()
        httpObj.reconnect_check_my_table_view(sendDic) { (returnData) in
            self.updateReconnect(returnData)
        }
        
    }
    func updateReconnect(_ returnDic:Dictionary<String,AnyObject>) {
        // return_dic -- topic_id* -- topic_with_who* -- topic_content, last_speaker, is_online, topic_content_id
        
        for topic_id_s in returnDic{
            let topic_id = topic_id_s.0
            let topic_who = topic_id_s.1 as? Dictionary<String,AnyObject>
            if topic_who != nil {
                if topic_who?.count != 0{
                    for topic_who_s in topic_who!{
                        //修改資料庫
                        let detailData_s = topic_who![topic_who_s.0] as? Dictionary<String,AnyObject>
                        let dataBase = secTopic[topic_id]
                        let dataIndex = dataBase?.index(where: { (target) -> Bool in
                            if target.clientId_detial! == topic_id{
                                return true
                            }
                            else{return false}
                        })
                        if dataIndex != nil{
                            // 更新DB
                            secTopic[topic_id]![dataIndex!].lastLine_detial = detailData_s!["topic_content"] as? String
                            secTopic[topic_id]![dataIndex!].clientOnline_detial = detailData_s!["is_online"] as? Bool
                            secTopic[topic_id]![dataIndex!].lastSpeaker_detial = detailData_s!["last_speaker"] as? String
                            self.updataTitleUnread(topic_id)
                            
                            let mainDataBase = mytopic
                            let mainDataBaseIndex = mainDataBase.index(where: { (target) -> Bool in
                                if target.dataType == "detail"
                                && target.topicId_title! == topic_id
                                    && target.clientId_detial == topic_who_s.0{
                                    return true
                                }
                                else{return false}
                            })
                            if mainDataBaseIndex != nil{
                                // 更新畫面顯示
                                mytopic[mainDataBaseIndex!].lastLine_detial = detailData_s!["topic_content"] as? String
                                mytopic[mainDataBaseIndex!].clientOnline_detial = detailData_s!["is_online"] as? Bool
                                mytopic[mainDataBaseIndex!].lastSpeaker_detial = detailData_s!["last_speaker"] as? String
                                self.tableView.reloadData()
                            }
                            
                        }
                        else{
                            // topic_with_who* -- topic_content, last_speaker, is_online
                            let http_obj = HttpRequestCenter()
                            var sendDic:Dictionary<String,String> = [:]
                            sendDic["client_id"] = topic_who_s.0
                            sendDic["topic_content_id"] = detailData_s!["topic_content_id"] as? String
                            sendDic["topic_id"] = topic_id
                            DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async(execute: {
                                http_obj.reconnect_update_new_user_data(sendDic as NSDictionary, InViewAct: { (returnData) in
                                    let new_sec_cell_DB = self.transferToStandardType_detail(returnData)
                                    if !new_sec_cell_DB.isEmpty{
                                        let topic_id = new_sec_cell_DB[0].topicId_title!
                                        if self.secTopic[topic_id] != nil{
                                            self.secTopic[topic_id]! += new_sec_cell_DB
                                        }
                                        else{
                                            self.secTopic[topic_id] = new_sec_cell_DB
                                        }
                                    }
                                    
                                })
                            })
                        }

                    }
                }
            }
        }
        
    }
 
    
}

