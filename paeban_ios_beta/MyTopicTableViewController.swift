//
//  MyTopicTableViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

// 我的話題清單
class MyTopicTableViewController: UITableViewController,webSocketActiveCenterDelegate,webSocketActiveCenterDelegate_re ,MyTopicTableViewModelDelegate{
    // fly 移除
    @IBAction func test_msg(_ sender: Any) {
        //socket.write(data: json_dumps(["msg_type":"cmd", "text": "revers_online_state"]))
        let dic = ["msg_type":"cmd", "text": "test_msg"]
        socket.write(data: json_dumps(dic as NSDictionary))
    }

    // MARK: Properties
    var model = MyTopicTableViewModel()
    
    var mytopic:Array<MyTopicStandardType> = []
    var secTopic:Dictionary<String,Array<MyTopicStandardType>>{
        get{return secTopic_x}
        set{
            secTopic_x = newValue
        }
    }
    var secTopic_x:Dictionary = [String: [MyTopicStandardType]]()
    var segueData:Dictionary<String, AnyObject> = [:]
    let heightOfCell:CGFloat = 85
    var heightOfSecCell:CGFloat = 130
    var selectItemId:String?
    var switchFirst = true
    var nowAcceptTopicId:String?
    var selectIndex:Int?
    
    // MARK: override
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        wsActive.wasd_ForMyTopicTableViewController = self
        self.tableView.tableFooterView = UIView()
        // 讓整個VIEW往上縮起tabbar的高度
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, (self.tabBarController?.tabBar.frame)!.height, 0);
    }
//    override func viewWillAppear(_ animated: Bool) {
//        model.main_loading_v2()
//        update_badges()
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        model.chat_view = nil
//        self.show_leave_topic_alert()
//        synchronize_tmp_client_Table { 
//            self.model.main_loading_v2()
//            self.model.chat_view?.re_new_client_img()
//        }
//    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topicWriteToRow = self.model.mytopic[(indexPath as NSIndexPath).row]
        if topicWriteToRow.dataType == "title"{
            // 父cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "myTopicCell_1", for: indexPath) as! MyTopicTableViewCell
//            let unredMsg = Float(topicWriteToRow.unReadMsg_title)
//            let allMsg = Float(topicWriteToRow.allMsg_title)
//            var readRate:Int
//            if topicWriteToRow.allMsg_title == 0{
//                readRate = 100
//            }
//            else{
//                readRate = Int((1-(unredMsg/allMsg))*100)
//            }
            cell.topicTitle.text = topicWriteToRow.topicTitle_title
            //cell.unReadM.text = String(readRate)+"%"
            if topicWriteToRow.battery != nil{
                cell.unReadM.text = "\(topicWriteToRow.battery!)%"
            }
            
            cell.myTopicHashtag.tagListInContorller = topicWriteToRow.tag_detial
            cell.myTopicHashtag.drawButton()
            
            // 給ET：之後要加入電池的選項CASE對應參數
            
            //letoutBattery(battery: cell.myTopicbattery, batteryLeft: readRate)
            if topicWriteToRow.battery != nil{
                letoutBattery(battery: cell.myTopicbattery, batteryLeft: topicWriteToRow.battery!)
            }
            
            return cell
        }
        else if topicWriteToRow.dataType == "detail"{
            // 子cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "myTopicCell_2", for: indexPath) as! TopicSecTableViewCell
            cell.clientName.text = topicWriteToRow.clientName_detial
            cell.speaker.text = topicWriteToRow.lastSpeaker_detial
            cell.lastLine.text = topicWriteToRow.lastLine_detial
            cell.photo.image = topicWriteToRow.clientPhoto_detial
            if topicWriteToRow.clientSex_detial != nil{
                cell.sexLogo = letoutSexLogo(sexImg:cell.sexLogo, sex: topicWriteToRow.clientSex_detial!)
            }
            if topicWriteToRow.clientOnline_detial != nil{
                letoutOnlineLogo(topicWriteToRow.clientOnline_detial!,cellOnlineLogo: cell.onlineLogo)
            }
            if topicWriteToRow.clientIsRealPhoto_detial != nil{
                letoutIsTruePhoto(topicWriteToRow.clientIsRealPhoto_detial!,isMeImg: cell.isTruePhoto)
            }
            
            if topicWriteToRow.read_detial == false && topicWriteToRow.lastSpeaker_detial != userData.name{
                cell.lastLine.textColor = UIColor(red:0.97, green:0.49, blue:0.31, alpha:1.0)
//                cell.lastLine.font = UIFont.boldSystemFont(ofSize: 16)
            }
            else{
                cell.lastLine.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
//                cell.lastLine.font = UIFont.systemFont(ofSize: 16)
            }
            
            
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
            var data_dic:Dictionary<String,AnyObject> = [:]
            let nextView = segue.destination as! MyTopicViewController
            
            if self.tableView.indexPathForSelectedRow != nil{
                //用選擇的方式
                let indexPath = self.tableView.indexPathForSelectedRow!
                let dataposition:Int = (indexPath as NSIndexPath).row
                let data = model.mytopic[dataposition]
                data_dic["client_id"] = data.clientId_detial as AnyObject
                data_dic["topic_id"] = data.topicId_title as AnyObject
                data_dic["topic_tiitle"] = data.topicTitle_title as AnyObject
            }
            else{
                data_dic = self.segueData
            }
            nextView.setID = data_dic["client_id"] as? String
            nextView.topicId = data_dic["topic_id"] as? String
            nextView.topicTitle = data_dic["topic_tiitle"] as? String
            nextView.model = self.model
            model.chat_view = nextView
            self.segueData = [:]
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return (model.mytopic.count)}
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.did_select_row(index: indexPath.row)
//        let cellIndex = (indexPath as NSIndexPath).row
//        var actMode = false
//        if mytopic[cellIndex].dataType == "title"{
//            if cellIndex == mytopic.count-1{
//                actMode = true
//            }
//            else if mytopic[cellIndex + 1].dataType != "detail"{
//                actMode = true
//            }
//            if actMode{
//                // 伸展子cell
//                topic_content_read(topic_id: mytopic[cellIndex].topicId_title!)
//                badge_update()
//                let topicId_title = mytopic[cellIndex].topicId_title
//                
//                updateSelectIndex(topicId_title!, anyFunction: {
//                    self.removeLoadingCell()
//                    self.collectCell()
//                })
//                getSecCellData(mytopic[indexPath.row].topicId_title!,selectIndex: indexPath.row)
//            }
//            else{
//                //縮回子cell
//                if let topicId_title = mytopic[cellIndex].topicId_title{
//                    updateSelectIndex(topicId_title, anyFunction: {
//                        self.removeLoadingCell()
//                    })
//                }
//                let dataLen = mytopic.count
//                var removeRowList = [IndexPath]()
//                var removeIndexList = [Int]()
//                for removeIndex in (selectIndex!+1)..<dataLen{
//                    if mytopic[removeIndex].dataType == "detail"{
//                        removeIndexList.insert(removeIndex, at: 0)
//                        let removeRow = IndexPath(row: removeIndex, section: 0)
//                        removeRowList += [removeRow]
//                    }
//                    else{
//                        break
//                    }
//                }
//                for removeIndex in removeIndexList{
//                    mytopic.remove(at: removeIndex)
//                }
//                self.tableView.beginUpdates()
//                self.tableView.deleteRows(at: removeRowList, with: UITableViewRowAnimation.automatic)
//                self.tableView.endUpdates()
//                self.tableView.deselectRow(at: indexPath, animated: true)
//            }
//        }

    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let data = model.mytopic[indexPath.row]
        let close_topic_btn = UITableViewRowAction(style: .default, title: "全部關閉") { (UITableViewRowAction_parameter, IndexPath_parameter) in
            let alert = UIAlertController(title: "警告", message: "即將關閉話題，並移除所有參加者", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (act) in
                self.model.close_topic(index: IndexPath_parameter.row)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        let delete = UITableViewRowAction(style: .default, title: "刪除") { (UITableViewRowAction_parameter, IndexPath_parameter) in
            let alert = UIAlertController(title: "警告", message: "將用戶踢出話題？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (act) in
                let data = self.model.mytopic[IndexPath_parameter.row]
                Ignore_list_center().add_ignore_list(topic_id_in: data.topicId_title!, client_id: data.clientId_detial!)
                self.model.delete_detail_cell(index: IndexPath_parameter.row)
                self.update_badges()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        let report = UITableViewRowAction(style: .default, title: "舉報".localized(withComment: "MyTopicTableViewController")) { (UITableViewRowAction_parameter, IndexPath_parameter) in
            let block_id = data.clientId_detial!
            let topic_id = data.topicId_title!
            let client_name = data.clientName_detial!
            self.reportAbuse(topic_id: topic_id, client_id: block_id, client_name: client_name)
        }
        let block = UITableViewRowAction(style: .default, title: "封鎖".localized(withComment: "MyTopicTableViewController")) { (UITableViewRowAction_parameter, IndexPath_parameter) in
            let block_id = data.clientId_detial!
            let client_name = data.clientName_detial!
            self.block(block_id: block_id, client_name: client_name)
        }
        block.backgroundColor = UIColor.red
        close_topic_btn.backgroundColor = UIColor.black
        delete.backgroundColor = UIColor.gray
        report.backgroundColor = UIColor.black
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
            //model.main_loading_v2()
        }
        else if msg["msg_type"] as! String == "new_topic"{
            for msg_keys in msg.keys{
                if msg_keys != "msg_type"{
                    let msg_vals = msg[msg_keys] as! Dictionary<String,AnyObject>
                    if let topic_publisher = msg_vals["topic_publisher"] as? String{
                        if topic_publisher == userData.id{
                            model.main_loading_v2()
                            break
                        }
                    }
                }
            }
        }
        else if msg["msg_type"] as! String == "topic_closed"{
            let topic_id = msg["topic_id"] as? String
            if topic_id != nil{
                model.topic_closed(topic_id:topic_id!)
            }
        }
        else if msg["msg_type"] as! String == "off_line"{
            model.socket_client_OFF_line_signal(msg: msg)
        }
        else if msg["msg_type"] as! String == "new_member"{
            model.socket_client_ON_line_signal(msg: msg)
        }
        else if msg["msg_type"] as! String == "friend_confirm"{
            fast_alter(inviter: (msg["sender_name"] as? String)!, nav_controller: self.parent as! UINavigationController)
        }
        else if msg["msg_type"] as! String == "leave_topic_owner"{
            let topic_id = msg["topic_id"] as! String
            let client_name = msg["client_name"] as! String
            self.model.add_topic_closed_list(topic_id: topic_id, client_name: client_name)
            self.show_leave_topic_alert()
            model.main_loading()
            update_badges()
        }
//        else if msg["msg_type"] as! String == "leave_topic_master"{
//            let topic_id = msg["topic_id"] as! String
//            let client_id = msg["client_id"] as! String
//            sql_database.remove_topic_from_leave_topic_master_table(topic_id_input: topic_id, client_id_input: client_id)
//            
//        }
    }
//    func new_my_topic_msg(sender:String, id_local:String){
//        model.main_loading_v2()
//    }
    @objc func new_client_topic_msg(sender: String) {
        print("==new_my_topic_msg==")
        model.main_loading_v2()
    }
    
    func wsReconnected(){
        //self.model.send_leave_topic_master()
        model.main_loading_v2()
        update_badges()
    }
    func brake(){
        let table_list = model.mytopic
        let list_count = table_list.count
        
        if list_count < 6{
            //print("brike")
        }
    }
    func model_relodata(){
        self.tableView.reloadData()
        brake()
    }
    func model_relod_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation){
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: index_path_list, with: option)
        self.tableView.endUpdates()
        brake()
    }
    func model_delete_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation){
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: index_path_list, with: option)
        self.tableView.endUpdates()
        brake()
    }
    func model_insert_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation){
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: index_path_list, with: option)
        self.tableView.endUpdates()
        brake()
    }
    func segue_to_chat_view(detail_cell_obj:MyTopicStandardType){
//        self.segueData = detail_cell_obj
//        self.performSegue(withIdentifier: "masterModeSegue", sender: nil)
    }
    // MARK: 內部函數
    // MARK: ===施工中===
    func show_leave_topic_alert(){
        if self.model.chat_view == nil{
            for alert_data in self.model.topic_leave_list{
                let alert = UIAlertController(title: "通知".localized(withComment: "MyTopicTableViewController"), message: String(format: NSLocalizedString("用戶%@ 已離開您的話題%@", comment: "MyTopicTableViewController"), alert_data["client_name"]!, alert_data["topic_title"]!), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確認".localized(withComment: "MyTopicTableViewController"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.model.topic_leave_list = []
        }
    }
//    func send_leave_topic_master(){
//        let send_list = sql_database.get_leave_topic_master_table_list()
//        for send_data in send_list{
//            let send_dic:NSDictionary = [
//                "msg_type": "leave_topic_master",
//                "topic_id": send_data["topic_id"]!,
//                "client_id": send_data["client_id"]!
//            ]
//            socket.write(data: json_dumps(send_dic))
//        }
//    }
    
    // ===施工中===
    func update_badges(){
        let tab_bar = self.parent?.parent as! TabBarController
        tab_bar.update_badges()
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
    
    func block(block_id:String, client_name:String){
        let confirm = UIAlertController(title: "封鎖".localized(withComment: "MyTopicTableViewController"), message: String(format: NSLocalizedString("封鎖%@ ? 本話題不會再出現此用戶", comment: "MyTopicTableViewController"), client_name), preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消".localized(withComment: "MyTopicTableViewController"), style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicTableViewController"), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.model.remove_detail_cell(by: block_id)
            self.model.remove_sec_topic_data(client_id:block_id)
            Block_list_center().add_user_to_block_list(client_id: block_id)
        }))
        self.present(confirm, animated: true, completion: nil)
        
    }
//    func block(topic_id:String, block_id:String, client_name:String){
//        let data:NSDictionary = [
//            "block_id":block_id,
//            "topic_id":topic_id
//        ]
//        let confirm = UIAlertController(title: "封鎖".localized(withComment: "MyTopicTableViewController"), message: String(format: NSLocalizedString("封鎖%@ ? 本話題不會再出現此用戶", comment: "MyTopicTableViewController"), client_name), preferredStyle: UIAlertControllerStyle.alert)
//        confirm.addAction(UIAlertAction(title: "取消".localized(withComment: "MyTopicTableViewController"), style: UIAlertActionStyle.default, handler: nil))
//        confirm.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicTableViewController"), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
//            self.model.remove_detail_cell(by: block_id)
//            HttpRequestCenter().privacy_function(msg_type:"block", send_dic: data) { (Dictionary) in
//                if let _ = Dictionary.index(where: { (key: String, value: AnyObject) -> Bool in
//                    if key == "msgtype"{
//                        return true
//                    }
//                    else{return false}
//                }){
//                    if Dictionary["msgtype"] as! String == "block_success"{
//                        //code
//                    }
//                }
//            }
//        }))
//        self.present(confirm, animated: true, completion: nil)
//        
//    }
    func reportAbuse(topic_id:String, client_id:String, client_name:String){
        let sendDic:NSDictionary = [
            "report_id":client_id,
            "topic_id":topic_id
        ]
        let confirm = UIAlertController(title: "舉報".localized(withComment: "MyTopicTableViewController"), message: String(format: NSLocalizedString("向管理員反應收到%@ 的騷擾內容", comment: "MyTopicTableViewController"), client_name), preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消".localized(withComment: "MyTopicTableViewController"), style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicTableViewController"), style: UIAlertActionStyle.default, handler: { (UIAlertAction_void) in
            HttpRequestCenter().privacy_function(msg_type: "report_topic", send_dic: sendDic, inViewAct: { (Dictionary) in
                let msg_type = Dictionary["msg_type"] as! String
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: nil))
                if msg_type == "success"{
                    alert.title = "舉報".localized(withComment: "MyTopicTableViewController")
                    alert.message = "感謝您的回報，我們將儘速處理".localized(withComment: "MyTopicTableViewController")
                    
                }
                else if msg_type == "user_not_exist"{
                    alert.title = "錯誤".localized(withComment: "MyTopicTableViewController")
                    alert.message = "用戶不存在".localized(withComment: "MyTopicTableViewController")
                }
                else if msg_type == "topic_not_exist"{
                    alert.title = "錯誤".localized(withComment: "MyTopicTableViewController")
                    alert.message = "話題不存在".localized(withComment: "MyTopicTableViewController")
                }
                else if msg_type == "unknown_error"{
                    alert.title = "錯誤".localized(withComment: "MyTopicTableViewController")
                    alert.message = "未知的錯誤".localized(withComment: "MyTopicTableViewController")
                }
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                    
                }
            })
        }))
        self.present(confirm, animated: true, completion: nil)
        
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
    func pop_to_root_view(){
        let parent = self.parent as! UINavigationController
        parent.popToRootViewController(animated: false)
    }
    func autoLeap(segeu_data:Dictionary<String,String>){
        if !segeu_data.isEmpty{
            print("dkdkdk")
            print(Date().timeIntervalSince1970)
            let segue_topic_id = segeu_data["topic_id"]
            let segue_user_id = segeu_data["user_id"]
            self.segueData["topic_id"] = segue_topic_id! as AnyObject
            self.segueData["client_id"] = segue_user_id! as AnyObject
            if let topic_title = sql_database.get_recent_title(topic_id: segue_topic_id!){
                self.segueData["topicTitle"] = topic_title as AnyObject
            }
            self.performSegue(withIdentifier: "masterModeSegue", sender: nil)
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
            alert.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicTableViewController"), style: UIAlertActionStyle.default, handler: nil))
            if msg_type == "success"{
                alert.title = "舉報".localized(withComment: "MyTopicTableViewController")
                alert.message = "感謝您的回報，我們將儘速處理".localized(withComment: "MyTopicTableViewController")
                
            }
            else if msg_type == "user_not_exist"{
                alert.title = "錯誤".localized(withComment: "MyTopicTableViewController")
                alert.message = "用戶不存在".localized(withComment: "MyTopicTableViewController")
            }
            else if msg_type == "topic_not_exist"{
                alert.title = "錯誤".localized(withComment: "MyTopicTableViewController")
                alert.message = "話題不存在".localized(withComment: "MyTopicTableViewController")
            }
            else if msg_type == "unknown_error"{
                alert.title = "錯誤".localized(withComment: "MyTopicTableViewController")
                alert.message = "未知的錯誤".localized(withComment: "MyTopicTableViewController")
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
        alert.addAction(UIAlertAction(title: "取消".localized(withComment: "MyTopicTableViewController"), style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicTableViewController"), style: .default, handler: { (_) in
            yes_func()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //設定cell 裡面的圖示

    //之後要加入電池的選項CASE
    func letoutBattery(battery:UIImageView, batteryLeft:Int){
        if batteryLeft <= 30{
            battery.image = UIImage(named:"battery-low")
        }
        else if batteryLeft <= 50{
            battery.image = UIImage(named:"battery-half")
        }
        else if batteryLeft <= 80{
            battery.image = UIImage(named:"battery-good")
        }
        else if batteryLeft <= 100{
            battery.image = UIImage(named:"battery-full")
        }
    }
    func letoutSexLogo(sexImg:UIImageView, sex:String) -> UIImageView {
        switch sex {
        case "男":
            sexImg.image = UIImage(named: "male")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            sexImg.tintColor = UIColor(red:0.27, green:0.71, blue:0.88, alpha:1.0)
        case "女":
            sexImg.image = UIImage(named:"female")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            sexImg.tintColor = UIColor(red:1.00, green:0.49, blue:0.42, alpha:1.0)
        case "男同":
            sexImg.image = UIImage(named:"gay")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            sexImg.tintColor = UIColor(red:0.27, green:0.71, blue:0.88, alpha:1.0)
        case "女同":
            sexImg.image = UIImage(named:"lesbain")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            sexImg.tintColor = UIColor(red:1.00, green:0.49, blue:0.42, alpha:1.0)
        default:
            sexImg.image = nil
            print("性別圖示分類失敗")
        }
        return sexImg
    }
    func letoutIsTruePhoto(_ isTruePhoto:Bool,isMeImg:UIImageView){
        isMeImg.image = UIImage(named:"True_photo")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        isMeImg.layoutIfNeeded()
        let cr = (isMeImg.frame.size.width)/2
//        isMeImg.layer.borderWidth = 1
//        isMeImg.layer.borderColor = UIColor.white.cgColor
        isMeImg.layer.cornerRadius = cr
        isMeImg.clipsToBounds = true
        if isTruePhoto{
            isMeImg.tintColor = UIColor.white
        }
        else{
            isMeImg.tintColor = UIColor.clear
        }
    }
    func letoutOnlineLogo(_ isOnline:Bool,cellOnlineLogo:UIImageView){
        cellOnlineLogo.layoutIfNeeded()
        cellOnlineLogo.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let cr = (cellOnlineLogo.frame.size.width)/2
        cellOnlineLogo.layer.borderWidth = 1
        cellOnlineLogo.layer.borderColor = UIColor.white.cgColor
        cellOnlineLogo.layer.cornerRadius = cr
        cellOnlineLogo.clipsToBounds = true
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




