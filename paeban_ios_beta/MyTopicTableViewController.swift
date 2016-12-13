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
    
    var secTopic:Dictionary<String,Array<MyTopicStandardType>>{
        get{return secTopic_x}
        set{
            secTopic_x = newValue
        }
    }
    var secTopic_x:Dictionary = [String: [MyTopicStandardType]]()
    var segueData:MyTopicStandardType?
    let heightOfCell:CGFloat = 85
    var heightOfSecCell:CGFloat = 130
    var selectItemId:String?
    var switchFirst = true
    var nowAcceptTopicId:String?
    var selectIndex:Int?
    
    // MARK: override
    override func viewDidLoad() {
        super.viewDidLoad()
        wsActive.wasd_ForMyTopicTableViewController = self
        wsActive.ware_ForMyTopicTableViewController = self
        self.tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        get_my_topic_title()
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
            cell.myTopicHashtag.tagListInContorller = topicWriteToRow.tag_detial
            cell.myTopicHashtag.drawButton()
            
            // 給ET：之後要加入電池的選項CASE對應參數
            letoutBattery(battery: cell.myTopicbattery)
            
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
            
            // 切子cell照片圓角
            let myPhotoLayer:CALayer = cell.photo.layer
            myPhotoLayer.masksToBounds = true
            myPhotoLayer.cornerRadius = 6
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! TableViewLoadingCell
            // 調整刷新圖示的地方
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: cell.frame.maxX, height: 70)
            //activityIndicator.center = cell.center
            activityIndicator.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            activityIndicator.startAnimating()
            cell.addSubview(activityIndicator)
            
            return cell
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "masterModeSegue"{
            var data:MyTopicStandardType
            let nextView = segue.destination as! MyTopicViewController
            
            if self.tableView.indexPathForSelectedRow != nil{
                //用選擇的方式
                let indexPath = self.tableView.indexPathForSelectedRow!
                let dataposition:Int = (indexPath as NSIndexPath).row
                
                data = mytopic[dataposition]
            }
            else{
                data = self.segueData!
            }
            nextView.setID = data.clientId_detial
            nextView.setName = data.clientName_detial
            nextView.topicId = data.topicId_title
            nextView.clientImg = data.clientPhoto_detial
            nextView.topicTitle = data.topicTitle_title
            nextView.title = data.clientName_detial
            
            self.segueData = nil
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return mytopic.count}
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
                topic_content_read(topic_id: mytopic[cellIndex].topicId_title!)
                badge_update()
                let topicId_title = mytopic[cellIndex].topicId_title
                
                updateSelectIndex(topicId_title!, anyFunction: {
                    self.removeLoadingCell()
                    self.collectCell()
                })
                getSecCellData(mytopic[indexPath.row].topicId_title!,selectIndex: indexPath.row)
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
//        else if mytopic[cellIndex].dataType == "detail"{
//            self.segueData = mytopic[cellIndex]
//            performSegue(withIdentifier: "masterModeSegue", sender: nil)
//        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let data = mytopic[indexPath.row]
        let close_topic_btn = UITableViewRowAction(style: .default, title: "close") { (UITableViewRowAction_parameter, IndexPath_parameter) in
            self.remove_cell(index: IndexPath_parameter.row)
        }
        let delete = UITableViewRowAction(style: .default, title: "delete") { (UITableViewRowAction_parameter, IndexPath_parameter) in
            self.remove_cell(index: IndexPath_parameter.row)
        }
        let report = UITableViewRowAction(style: .default, title: "report") { (UITableViewRowAction_parameter, IndexPath_parameter) in
            //code
        }
        let block = UITableViewRowAction(style: .default, title: "block") { (UITableViewRowAction_parameter, IndexPath_parameter) in
            //code
        }
        block.backgroundColor = UIColor.red
        close_topic_btn.backgroundColor = UIColor.green
        delete.backgroundColor = UIColor.gray
        report.backgroundColor = UIColor.blue
        if data.dataType == "title"{
            return [close_topic_btn]
        }
        else{
            return [delete, report, block]
        }
    }
    
    
    // MARK: delegate
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        if msg["msg_type"] as! String == "topic_msg"{
            updataSecTopic(msg)
        }
        else if msg["msg_type"] as! String == "new_topic"{
            for msg_keys in msg.keys{
                if msg_keys != "msg_type"{
                    let msg_vals = msg[msg_keys] as! Dictionary<String,AnyObject>
                    if let topic_publisher = msg_vals["topic_publisher"] as? String{
                        if topic_publisher == userData.id{
                            get_my_topic_title()
                            break
                        }
                    }
                }
            }
        }
    }
    func wsReconnected(){
        //dic -- title* -- detail* --
        checkData()
    }
    
    // MARK: 內部函數
    // ===施工中===
    func updataSecTopic(_ msg:Dictionary<String,AnyObject>){
        // msg -- msg_type:"topic_msg"
        //     -- img:String
        //     -- result_dic --topic_content_id* -- sender:String
        //                                       -- temp_topic_msg_id
        //                                       -- topic_content
        //                                       -- receiver
        //                                       -- topic_id
        
        let result_dic = msg["result_dic"] as! Dictionary<String,Dictionary<String,String>>
        for topic_content_id in result_dic{
            let topic_content_data = topic_content_id.1
            let topic_id = topic_content_data["topic_id"]!
            if let _ = secTopic.index(where: { (key, _) -> Bool in
                if key == topic_id{
                    return true
                }
                return false
            }){
                //本地端已有該話題
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
                    //新建資料
                    request_sec_topic_config(topic_id: topic_id, topicWithWho: topicWithWho, topic_content_id: topic_content_id.key, any_func: {(cell_obj) in
                        if topic_content_data["sender"] == userData.id{
                            cell_obj.lastSpeaker_detial = userData.name
                        }
                        else{
                            cell_obj.lastSpeaker_detial = cell_obj.clientName_detial
                        }
                        
                        cell_obj.lastLine_detial = topic_content_data["topic_content"]
                        self.secTopic[topic_id]?.append(cell_obj)
                        DispatchQueue.main.async {
                            self.updataTitleUnread(topic_id)
                            self.tableView.reloadData()
                        }
                        
                        
                    })
                    
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
    
    func request_sec_topic_config(topic_id:String, topicWithWho:String, topic_content_id:String, any_func:@escaping (MyTopicStandardType)->Void){
        
        HttpRequestCenter().request_topic_msg_config(topic_id, client_id: topicWithWho, topic_content_id: topic_content_id, InViewAct: { (return_dic) in
            let detail_cell_obj = MyTopicStandardType(dataType: "detail")
            detail_cell_obj.topicId_title = topic_id
            detail_cell_obj.clientId_detial = topicWithWho
            detail_cell_obj.clientName_detial = return_dic["client_name"] as? String
            detail_cell_obj.topicContentId_detial = return_dic["topic_content_id"] as? String
            let img_string = return_dic["img"] as! String
            detail_cell_obj.clientPhoto_detial = base64ToImage(img_string)
            detail_cell_obj.clientSex_detial = return_dic["client_sex"] as? String
            detail_cell_obj.clientOnline_detial = false
            detail_cell_obj.clientIsRealPhoto_detial = return_dic["client_is_real_photo"] as? Bool
            detail_cell_obj.read_detial = return_dic["read"] as? Bool
            
            any_func(detail_cell_obj)
        })
    }
    
    // ===施工中===
    // 查詢線上問題待解決 鮮血入 false
    func badge_update(){
        HttpRequestCenter().msg_func(msg_type: "check_badge", send_dic: [:]) { (retuen_dic) in
            if let badge_count = Int(retuen_dic["badge_count"] as! String){
                app_instence?.applicationIconBadgeNumber = badge_count
            }
        }
    }
    func topic_content_read(topic_id:String){
        var read_id_list:Array<String> = []
        if secTopic[topic_id] != nil{
            let cell_obj_list = secTopic[topic_id]!
            for cell_obj in cell_obj_list{
                if !cell_obj.read_detial!{
                    cell_obj.read_detial = true
                    read_id_list.append(cell_obj.topicContentId_detial!)
                }
            }
        }
        if !read_id_list.isEmpty{
            for read_id_list_s in read_id_list{
                let send_dic:NSDictionary = [
                    "msg_type": "topic_content_read",
                    "topic_content_id":read_id_list_s
                ]
                socket.write(data: json_dumps(send_dic))
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
                let download_data = self.transferToStandardType_title(returnData)
                if self.check_title_cell_is_need_update(check_data: download_data){
                    DispatchQueue.main.async(execute: {
                        self.mytopic = download_data
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    func check_title_cell_is_need_update(check_data:Array<MyTopicStandardType>) -> Bool{
        for check_data_s in check_data{
            if let _ = mytopic.index(where: { (MyTopicStandardType_parameter) -> Bool in
                if check_data_s.topicId_title == MyTopicStandardType_parameter.topicId_title{
                    return true
                }
                return false
            }){
                //pass
            }
            else{
                return true
            }
        }
        return false
    }
    func get_my_topic_detail(_ topicId:String){
        DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async{ () -> Void in
            let httpObj = HttpRequestCenter()
            httpObj.get_my_topic_detail(topicId, InViewAct: { (returnData) in
                DispatchQueue.main.async(execute: {
                    let topicId = returnData["topic_id"] as! String
                    let returnDataList = self.transferToStandardType_detail(returnData)
                    if self.check_detail_cell_is_need_update(topic_id: topicId, check_data: returnDataList){
                        self.secTopic[topicId] = returnDataList
                    }
                    print("第\(self.secTopic.count)筆詳細資料下載完畢")
                })
            })
        }
    }
    func check_detail_cell_is_need_update(topic_id:String, check_data:Array<MyTopicStandardType>) -> Bool{
        if self.secTopic[topic_id] == nil{
            return true
        }
        else{
            for check_data_s in check_data{
                if let _ = self.secTopic[topic_id]?.index(where: { (element) -> Bool in
                    if check_data_s.clientId_detial == element.clientId_detial{
                        return true
                    }
                    return false
                }){
                    //pass
                }
                else{return true}
            }
            return false
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
            topicTitleData.tag_detial = (topic_id.1 as! Dictionary<String,AnyObject>)["hash_tag"] as? Array<String>
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
    func autoLeap(){
        if notificationSegueInf != [:]{
            let parent = self.parent as! UINavigationController
            parent.popToRootViewController(animated: false)
            let segue_topic_id = notificationSegueInf["topic_id"]
            let segue_user_id = notificationSegueInf["user_id"]
            
            var targetData_Dickey:DictionaryIndex<String, [MyTopicStandardType]>?
            var targetData_Dicval:Array<MyTopicStandardType>.Index?
            
            var while_pertect = 5000
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                while targetData_Dickey == nil && targetData_Dicval == nil && while_pertect >= 0{
                    
                    targetData_Dickey = self.secTopic.index(where: { (key: String, value: [MyTopicStandardType]) -> Bool in
                        if key == segue_topic_id{
                            return true
                        }
                        else{return false}
                    })
                    
                    if targetData_Dickey != nil{
                        let dic_key_obj = self.secTopic[targetData_Dickey!].value
                        targetData_Dicval = dic_key_obj.index(where: { (MyTopicStandardType) -> Bool in
                            if MyTopicStandardType.clientId_detial == segue_user_id{
                                return true
                            }
                            else{return false}
                        })
                    }
                    
                    if targetData_Dickey != nil && targetData_Dicval != nil{
                        DispatchQueue.main.async {
                            self.segueData = self.secTopic[targetData_Dickey!].value[targetData_Dicval!]
                            self.performSegue(withIdentifier: "masterModeSegue", sender: nil)
                            notificationSegueInf = [:]
                        }
                        
                    }
                    usleep(100000)
                    while_pertect -= 100
                }
                self.segueData = nil
                notificationSegueInf = [:]
            }
            
        }
    }
        // 左滑選項的函數
    func close_topic(topic_id:String){
        let send_dic:NSDictionary = [
            "msg_type": "close_topic_btn",
            "topic_id":topic_id
        ]
        socket.write(data: json_dumps(send_dic))
    }
    func ignore_topic(topic_id:String, topic_black_id:String){
        let send_dic:NSDictionary = [
            "msg_type": "topic_black",
            "topic_id": topic_id,
            "topic_black_id":topic_black_id
        ]
        socket.write(data: json_dumps(send_dic))
    }
    func report_client(setID:String, topicId:String){
        let sendDic:NSDictionary = [
            "report_id":setID,
            "topic_id":topicId
        ]
        HttpRequestCenter().privacy_function(msg_type: "report_topic", send_dic: sendDic, inViewAct: { (Dictionary) in
            let msg_type = Dictionary["msg_type"] as! String
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: nil))
            if msg_type == "success"{
                alert.title = "舉報"
                alert.message = "感謝您的回報，我們將儘速處理"
                
            }
            else if msg_type == "user_not_exist"{
                alert.title = "錯誤"
                alert.message = "用戶不存在"
            }
            else if msg_type == "topic_not_exist"{
                alert.title = "錯誤"
                alert.message = "話題不存在"
            }
            else if msg_type == "unknown_error"{
                alert.title = "錯誤"
                alert.message = "未知的錯誤"
            }
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    func block_client(setID:String, topicId:String){
        let data:NSDictionary = [
            "block_id":setID,
            "topic_id":topicId
        ]
        HttpRequestCenter().privacy_function(msg_type:"block", send_dic: data) { (Dictionary) in
            if let _ = Dictionary.index(where: { (key: String, value: AnyObject) -> Bool in
                if key == "msgtype"{
                    return true
                }
                else{return false}
            }){
                if Dictionary["msgtype"] as! String == "block_success"{
                    //code
                }
            }
        }
    }
    func remove_cell(index:Int){
        if mytopic[index].dataType == "title"{
            let remove_detial_index = index + 1
            //remove_detial_index < mytopic.count
            while remove_detial_index < mytopic.count &&
                mytopic[remove_detial_index].dataType == "detail"{
                    remove_singo_cell(index: remove_detial_index)
            }
            let topic_id = mytopic[index].topicId_title
            if secTopic[topic_id!] != nil{
                secTopic[topic_id!] = nil
            }
            remove_singo_cell(index: index)
        }
        else{
            remove_singo_cell(index: index)
        }
        
    }
    func remove_singo_cell(index:Int){
        var index_path_list:Array<IndexPath> = []
        if mytopic[index].dataType == "detail"{
            let topic_id = mytopic[index].topicId_title
            let user_id = mytopic[index].clientId_detial
            if let database = secTopic[topic_id!]{
                if let index = database.index(where: { (MyTopicStandardType_obj) -> Bool in
                    if MyTopicStandardType_obj.clientId_detial == user_id{
                        return true
                    }
                    return false
                }){
                    secTopic[topic_id!]?.remove(at: index as Int)
                    self.updataTitleUnread(topic_id!)
//                    if (secTopic[topic_id!]?.isEmpty)!{
//                        secTopic[topic_id!] = nil
//                        if let list_index = mytopic.index(where: { (MyTopicStandardType_obj) -> Bool in
//                            if MyTopicStandardType_obj.topicId_title == topic_id{
//                                return true
//                            }
//                            return false
//                        }){
//                            mytopic.remove(at: list_index as Int)
//                            let index_path = IndexPath(row: list_index as Int, section: 0)
//                            index_path_list.append(index_path)
//                        }
//                    }
                }
            }
        }
        
        mytopic.remove(at: index)
        let index_path = IndexPath(row: index, section: 0)
        index_path_list.append(index_path)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: index_path_list, with: .left)
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
    func conform_excute(title:String, msg:String, yes_func:@escaping ()->Void){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (_) in
            yes_func()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //設定cell 裡面的圖示

    //之後要加入電池的選項CASE
    func letoutBattery(battery:UIImageView){
        battery.image = UIImage(named:"battery-low")
//        battery.tintColor = UIColor.red
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
                                        //let topic_id = new_sec_cell_DB[0].topicId_title!
                                        self.update_sec_topic(new_list: new_sec_cell_DB)
                                    }
                                    
                                })
                            })
                        }

                    }
                }
            }
        }
        
    }
    func update_sec_topic(new_list:Array<MyTopicStandardType>){
        for new_list_s in new_list{
            if secTopic[new_list_s.topicId_title!] == nil{
                secTopic[new_list_s.topicId_title!] = []
            }
            else{
                if let updeta_index = secTopic[new_list_s.topicId_title!]?.index(where: { (element) -> Bool in
                    if new_list_s.clientId_detial == element.clientId_detial{
                        return true
                    }
                    return false
                }){
                    secTopic[new_list_s.topicId_title!]?.remove(at: updeta_index as Int)
                    secTopic[new_list_s.topicId_title!]?.insert(new_list_s, at: updeta_index as Int)
                }
                else{
                    secTopic[new_list_s.topicId_title!]?.append(new_list_s)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }

    
    
}




