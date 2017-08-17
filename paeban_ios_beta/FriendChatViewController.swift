//
//  FriendChatViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class FriendChatViewController: JSQMessagesViewController, webSocketActiveCenterDelegate{
    // config
    let buff_msg_number = 0
    let max_load_msg_number = 50
    // config
    
    var messages = [JSQMessage3]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var setID:String? = "anonymous"
    var setName:String? = "anonymous"
    var clientId:String?
    var clientName:String?
    var loadHistorySwitch = false
    var workList:Array<Dictionary<String,AnyObject>> = []
    var sending_dic:Dictionary<String,Int> = [:]
    var scroll_point_save:CGPoint = CGPoint(x: 0, y: 0)
    var page_up_point:Int?
    var page_down_point:Int?
    var old_height:CGFloat?
    var old_position:CGFloat?
    
    //collectionView(_:attributedTextForMessageBubbleTopLabelAtIndexPath:)
    //MARK:讀入歷史訊息
    
    var topicNotExist:String?{
        get{return ""}
        set{
            //navigationController?.popViewController(animated: true)
        }
    }
    
    func addRequestMission(_ missionType:String,data:AnyObject){
        let wsSendList = ["request_history_priv_msg","priv_msg","priv_msg_been_read"]
        
        if let _ = wsSendList.index(of: missionType){
            var addDic:Dictionary<String,AnyObject> = [:]
            addDic["missionType"] = missionType as AnyObject?
            addDic["data"] = data
            removeWorkList("request_history_priv_msg", data: nil)
            workList.append(addDic)
            executeWork(addDic)
        }
    }
    
    func executeWork(_ dataDic:Dictionary<String,AnyObject>){
        let missionType = dataDic["missionType"] as! String
        let wsSendList = ["request_history_priv_msg","priv_msg","priv_msg_been_read"]
        if let _ = wsSendList.index(of: missionType){
            let sendData = dataDic["data"] as! NSDictionary
            if socketState{
                socket.write(data:json_dumps(sendData))
            }
        }
        
        if missionType == "request_history_priv_msg"{
            let sendData = dataDic["data"] as! Dictionary<String,String>
        }
    }
    
    func removeWorkList(_ missionType:String,data:AnyObject?) {
        if missionType == "request_history_priv_msg"{
            if let _ = workList.index(where: { (target) -> Bool in
                if target["missionType"] as! String == "request_history_priv_msg"{
                    return true
                }
                else{return false}
            }){
                var newList:Array<Dictionary<String,AnyObject>> = []
                for workList_s in workList{
                    if workList_s["missionType"] as! String != "request_history_priv_msg"{
                        newList.append(workList_s)
                    }
                }
                workList = newList
            }
        }
        else if missionType == "priv_msg"{
            if let removeDataIndex = workList.index(where: { (target) -> Bool in
                if target["missionType"] as! String == "priv_msg"{
                    let dataLocal = target["data"] as! Dictionary<String,AnyObject>
                    let dataIncom = data as! Dictionary<String,AnyObject>
                    if dataLocal["temp_priv_msg_id"] as! String == dataIncom["temp_priv_msg_id"] as! String{
                        return true
                    }
                    else{return false}
                }
                else{return false}
            }){
                workList.remove(at: removeDataIndex)
            }
        }
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return CGFloat(20)
    }
    //MARK:顯示"已讀"
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if messages[indexPath.item].isRead == true && messages[indexPath.item].senderId == userData.id{
            return NSAttributedString(string:"已讀")
        }
        else{
            return NSAttributedString(string:"")
        }
    }
    
    
    // 設定訊息顏色，用JSQ的套件
    fileprivate func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(
            with: UIColor.init(red:0.98, green:0.49, blue:0.29, alpha:1.0))
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(
            with: UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "好友"
        setupBubbles()
        //移除迴紋針按鈕
        self.inputToolbar.contentView.leftBarButtonItem = nil
        // 這兩個是初始化一定要有的參數
        //MARK:自己的參數
        senderId = setID
        senderDisplayName = setName
        dennis_kao_s_fucking_trash()
        
        // 監聽 contentSize 的變化
        self.collectionView?.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.add_tap()
        wsActive.wasd_ForFriendChatViewController = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        update_database(mode: .initial)
        update_database(mode: .change_resend_btn)
        let delegate_list = [wsActive.wasd_ForFriendChatViewController]
        update_private_mag(delegate_target_list: delegate_list)
        request_last_read_id_from_server_private()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: false, completion: nil)
        wsActive.wasd_ForFriendChatViewController = nil
        self.collectionView?.removeObserver(self, forKeyPath: "contentSize")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // 下面兩個負責讀取訊息
    // JSQ的列表顯示view, 在物件索引位至的訊息
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    // 此部份顯示物件的數量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    // 藉由 indexPath 來判定要畫成收到還是送出的信息
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    // 原本套件在每個信息前面有照片，這邊把他取消
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let message = messages[(indexPath as NSIndexPath).item]
        
        if message.senderId == senderId{
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! CustomMessagesCollectionViewCellOutgoing
            
            func hideResendBtn(cell:CustomMessagesCollectionViewCellOutgoing){
                cell.reloadBtnContainer.isHidden = true
                cell.resendingText.isHidden = true
            }
            func showResendBtn(cell:CustomMessagesCollectionViewCellOutgoing){
                cell.reloadBtnContainer.isHidden = false
                cell.reloadBTN.isHidden = false
                cell.reSending.stopAnimating()
                cell.resendingText.isHidden = true
            }
            func showResending(cell:CustomMessagesCollectionViewCellOutgoing){
                cell.reloadBtnContainer.isHidden = false
                cell.reloadBTN.isHidden = true
                cell.reSending.startAnimating()
                cell.resendingText.isHidden = false
            }

            cell.textView!.textColor = UIColor.white
            if message.show_resend_btn == true {
                if message.is_resending == true {
                    showResending(cell: cell)
                }
                else{
                    showResendBtn(cell: cell)
                }
            }
            else{
                hideResendBtn(cell: cell)
            }
            cell.frient_chat_view_controller = self
            
            let tap_event = UITapGestureRecognizer(target: self, action: #selector(self.dissmis_leybroad))
            cell.addGestureRecognizer(tap_event)
            return cell
        }
        else{
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
                as! CustomMessagesCollectionViewCellIncoming
            
            cell.textView!.textColor = UIColor.white
            let tap_event = UITapGestureRecognizer(target: self, action: #selector(self.dismiss_keybroad))
            cell.addGestureRecognizer(tap_event)
            return cell
        }
        
        
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == self.collectionView {
            scroll_recover()
        }
    }
    
    func dismiss_keybroad(){
        self.view.endEditing(true)
    }
    func addMessage(_ id: String, text: String) {
        let message = JSQMessage3(senderId: id, displayName: "", text: text)
        messages.append(message!)
    }
    // MARK:滾動中
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if page_up_point != nil{
            let page_up_point_check = self.collectionView.cellForItem(at: IndexPath(row: self.page_up_point!, section:0))?.bounds.height
            if page_up_point_check != nil{
                self.update_database(mode: .page_up)
            }
        }
    }
    func save_scroll_data(){
        old_height = self.collectionView.contentSize.height
        old_position = self.collectionView.contentOffset.y
    }
    func scroll_recover(){
        if old_height != nil && old_position != nil{
            let new_height = self.collectionView.contentSize.height
            self.collectionView.contentOffset.y = new_height - old_height! + old_position!
            old_height = nil
            old_position = nil
        }
    }
    func dennis_kao_s_fucking_trash(){
        // No avatars
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        //      上面要留白多高
        //      self.topContentAdditionalInset = 90
        
        //MARK: 跟自定義的泡泡關聯
        self.outgoingCellIdentifier = CustomMessagesCollectionViewCellOutgoing.cellReuseIdentifier()
        self.outgoingMediaCellIdentifier = CustomMessagesCollectionViewCellOutgoing.mediaCellReuseIdentifier()
        
        self.collectionView.register(CustomMessagesCollectionViewCellOutgoing.nib(), forCellWithReuseIdentifier: self.outgoingCellIdentifier)
        self.collectionView.register(CustomMessagesCollectionViewCellOutgoing.nib(), forCellWithReuseIdentifier: self.outgoingMediaCellIdentifier)
        
        self.incomingCellIdentifier = CustomMessagesCollectionViewCellIncoming.cellReuseIdentifier()
        self.incomingMediaCellIdentifier = CustomMessagesCollectionViewCellIncoming.mediaCellReuseIdentifier()
        
        self.collectionView.register(CustomMessagesCollectionViewCellIncoming.nib(), forCellWithReuseIdentifier: self.incomingCellIdentifier)
        self.collectionView.register(CustomMessagesCollectionViewCellIncoming.nib(), forCellWithReuseIdentifier: self.incomingMediaCellIdentifier)
    }
    
    
    //MARK:送出按鈕按下後
    override func didPressSend(_ button: UIButton?, withMessageText text: String?, senderId: String?, senderDisplayName: String?, date: Date?) {
        //送出WS訊息
        self.finishSendingMessage(animated: true)
        let timeNow = Int(Date().timeIntervalSince1970)
        let tempTopicMsgId = String(timeNow)
        let dataDic:Dictionary<String,AnyObject> = [
            "msg_type":"priv_msg" as AnyObject,
            "private_text":text! as AnyObject,
            "receiver_id":clientId! as AnyObject,
            "temp_priv_msg_id":tempTopicMsgId as AnyObject,
            "sender_id":userData.id! as AnyObject,
            "is_read":false as AnyObject,
            "is_send":false as AnyObject
        ]
        sql_database.inser_date_to_private_msg(input_dic: dataDic)
        self.update_database(mode: .new_client_msg)
        self.send_all_msg()
        
        
        
//        let appendMsg = JSQMessage3(senderId: senderId, displayName: senderDisplayName, text: text)
//        appendMsg?.topicTempid = tempTopicMsgId
//        self.messages.append(appendMsg!)
//        
//        self.finishSendingMessage(animated: true)
//        self.collectionView?.reloadData()
//        addRequestMission("priv_msg", data: dataDic)
    }
    // MARK:ws回傳信號
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        if msgType == "priv_msg_been_read"{
            //let msgId = String(msg["msg_id"] as! Int)
            let id_loacal = msg["id_local"] as! String
            sql_database.update_private_msg_read(id_local: id_loacal)
            update_database(mode: .change_read_state)
            
        }
        else if msgType == "has_been_read_many"{
            for msgIndex in 0 ..< messages.count{
                let reversMsgIndex = messages.count - msgIndex - 1
                if messages[reversMsgIndex].senderId == userData.id{
                    if messages[reversMsgIndex].isRead == false{
                        messages[reversMsgIndex].isRead = true
                    }
                    else{
                        self.collectionView.reloadData()
                        break
                    }
                }
            }
        }
        else if msgType == "online"{
            for workList_s in workList{
                executeWork(workList_s)
            }
        }
    }
    func wsReconnected(){
        send_read_to_server()
    }
    func new_client_topic_msg(sender: String) {
        if clientId == sender{
            update_database(mode: .new_client_msg)
            update_database(mode: .change_read_state)
        }
        (tabBar_pointer as? TabBarController)?.update_badges()
    }
    func new_my_topic_msg(sender: String, id_local: String) {
        sending_dic.removeValue(forKey: id_local)
        update_database(mode: .change_resend_btn)
    }
    func updataNowTopicCellList(_ resultDic:Dictionary<String,AnyObject>){
        
        for resultDicData in resultDic{
            let resultDicDataVal = resultDicData.1 as! Dictionary<String,AnyObject>
            let topicId = resultDicDataVal["topic_id"] as! String
            if let nowTopicCellListIndex = nowTopicCellList.index(where: { (target) -> Bool in
                if target.topicId_title == topicId{
                    return true
                }
                else{return false}
            }){
                nowTopicCellList[nowTopicCellListIndex].lastLine_detial = resultDicDataVal["topic_content"] as? String
                nowTopicCellList[nowTopicCellListIndex].lastSpeaker_detial = resultDicDataVal["sender"] as? String
            }
        }
        
    }
    func update_database(mode:load_data_mode){
        func set_page_up_point(){
            if messages.count >= max_load_msg_number{
                self.page_up_point = max_load_msg_number/3
            }
        }
        if mode == load_data_mode.initial{
            messages = new_data(mode: mode)
            self.collectionView.reloadData()
            self.scrollToBottom(animated: false)
            set_page_up_point()
        }
        else if mode == .page_up{
            if messages.count >= page_up_point! + 2{
                //let locked_point_id = messages[page_up_point! + 1].id_local!
                self.page_up_point = nil
                DispatchQueue.global(qos: .default).async {
                    let new_datas = self.new_data(mode: mode)
                    if !new_datas.isEmpty{
                        self.messages = self.new_data(mode: mode) + self.messages
                        DispatchQueue.main.async {
                            self.save_scroll_data()
                            self.collectionView.reloadData()
                            set_page_up_point()
                        }
                    }
                }
            }
        }
        else if mode == .new_client_msg{
            messages += new_data(mode: mode)
            self.collectionView.reloadData()
            self.scrollToBottom(animated: true)
            set_page_up_point()
        }
        else if mode == .change_read_state{
            for invers_index in 0..<messages.count{
                let index = messages.count - invers_index - 1
                if messages[index].isRead != true{
                    messages[index].isRead = sql_database.request_priv_msg_read_state(id_local: messages[index].id_local!)
                }
                else{
                    break
                }
            }
            self.collectionView.reloadData()
        }
        else if mode == .change_resend_btn{
            for invers_index in 0..<messages.count{
                let index = messages.count - invers_index - 1
                if let data = sql_database.request_msg_sending_state(id_local: messages[index].id_local!){
                    if data["is_send"] == nil || data["is_send"] as! Bool == false{
                        let time_now = Double(Date().timeIntervalSince1970)
                        let time_send = data["send_time"] as! Double
                        if time_now - time_send >= 2{
                            messages[index].show_resend_btn = true
                            if let _ = sending_dic.index(where: { (element) -> Bool in
                                if element.key == String(messages[index].id_local!) {
                                    return true
                                }
                                return false
                            }){
                                messages[index].is_resending = true
                            }
                            else{
                                messages[index].is_resending = false
                            }
                        }
                    }
                    else{
                        if messages[index].show_resend_btn{
                            messages[index].show_resend_btn = false
                        }
                        else{
                            break
                        }
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
    func new_data(mode:load_data_mode) -> Array<JSQMessage3>{
        // 檢查 sending_dic
        var new_message_list:Array<JSQMessage3> = []
        var data_dic:Array<Dictionary<String, AnyObject>> = []
        if mode == .initial{
            data_dic = sql_database.get_private_histopry_msg(mark_id: 0, buff_num: buff_msg_number , max_num: max_load_msg_number, client_id: clientId!, mode: mode)
        }
        else if mode == .page_up{
            let target_id = messages[0].id_local!
            data_dic = sql_database.get_private_histopry_msg(mark_id: target_id, buff_num: buff_msg_number , max_num: max_load_msg_number, client_id: clientId!, mode: mode)
        }
        else if mode == .new_client_msg{
            var target_id:Int64 = 0
            if messages.count > 0{
                target_id = messages[messages.count - 1].id_local!
            }
            data_dic = sql_database.get_private_histopry_msg(mark_id: target_id, buff_num: buff_msg_number , max_num: max_load_msg_number, client_id: clientId!, mode: mode)
            if data_dic.count > 1{
                var target_id_2:Int64 = 0
                for message_index in 0..<messages.count{
                    if messages[messages.count - message_index - 1].id_local! > target_id_2{
                        target_id_2 = messages[messages.count - message_index - 1].id_local!
                    }
                }
                data_dic = sql_database.get_private_histopry_msg(mark_id: target_id_2, buff_num: buff_msg_number , max_num: max_load_msg_number, client_id: clientId!, mode: mode)
            }
        }
        
        var last_read_id:String?
        for data_s in data_dic{
            new_message_list.append(make_JSQMessage3(input_dic: data_s))
            if (data_s["sender"] as! String) != userData.id && (data_s["is_read"] as! Bool) == false{
                last_read_id = data_s["id_server"] as? String
            }
        }
        // 發送已讀訊號
        if mode == .initial{
            if last_read_id != nil{
                let sendData = ["msg_type":"priv_msg_been_read",
                                "msg_id":last_read_id!]
                var addDic:Dictionary<String,AnyObject> = [:]
                addDic["missionType"] = "priv_msg_been_read" as AnyObject?
                addDic["data"] = sendData as AnyObject?
                executeWork(addDic)
            }
        }
        else if mode == .new_client_msg{
            if last_read_id != nil{
                let sendData = ["msg_type":"priv_msg_been_read",
                                "msg_id":last_read_id!]
                var addDic:Dictionary<String,AnyObject> = [:]
                addDic["missionType"] = "priv_msg_been_read" as AnyObject?
                addDic["data"] = sendData as AnyObject?
                executeWork(addDic)
            }
        }
        return new_message_list
    }
    func send_read_to_server(){
        if clientId != nil{
            let last_id = sql_database.get_private_msg_last_id_server(client_id_input: clientId!)
            let sendData = ["msg_type":"priv_msg_been_read",
                            "msg_id":last_id]
            var addDic:Dictionary<String,AnyObject> = [:]
            addDic["missionType"] = "priv_msg_been_read" as AnyObject?
            addDic["data"] = sendData as AnyObject?
            executeWork(addDic)
        }
    }
    func scroll_locked_point_to_top(locked_id:Int64){
        if let index = messages.index(where: { (ele:JSQMessage3) -> Bool in
            if ele.id_local == locked_id{
                return true
            }
            return false
        }){
            self.collectionView.scrollToItem(at: IndexPath(row:index, section:0), at: .top, animated: false)
        }
    }
    func scroll_locked_point_to_bottom(locked_id:Int64){
        if let index = messages.index(where: { (ele:JSQMessage3) -> Bool in
            if ele.id_local == locked_id{
                return true
            }
            return false
        }){
            self.collectionView.scrollToItem(at: IndexPath(row:index, section:0), at: .bottom, animated: false)
            if messages.count - index < 5{
                self.page_down_point = nil
            }
        }
    }
    func make_JSQMessage2(input_dic:Dictionary<String,AnyObject>) -> JSQMessage2{
        let msgToJSQ = JSQMessage2(senderId: input_dic["sender"] as? String, displayName: "non", text: input_dic["topic_content"] as? String)
        msgToJSQ?.isRead = input_dic["is_read"] as? Bool
        let is_send = input_dic["is_send"] as? Bool
        let write_time = Int(input_dic["write_time"] as! Double)
        let time_now = Int(Date().timeIntervalSince1970)
        let id_local = String(describing: input_dic["id_local"] as! Int64)
        if is_send == false && time_now - write_time >= 4 {
            msgToJSQ?.show_resend_btn = true
            if let _ = sending_dic.index(where: { (element) -> Bool in
                if element.key == String(id_local) {
                    return true
                }
                return false
            }){
                msgToJSQ?.is_resending = true
            }
        }
        return msgToJSQ!
    }
    func make_JSQMessage3(input_dic:Dictionary<String,AnyObject>) -> JSQMessage3{
        let msgToJSQ = JSQMessage3(senderId: input_dic["sender"] as? String, displayName: "non", text: input_dic["private_text"] as? String)
        msgToJSQ?.isRead = input_dic["is_read"] as? Bool
        //let is_send = input_dic["is_send"] as? Bool
        //let write_time_db = input_dic["write_time"]!
        //let write_time_db2:Double = write_time_db as! Double
        //let write_time = Int(write_time_db2)
        //let time_now = Int(Date().timeIntervalSince1970)
        let id_local_db = input_dic["id_local"]! as! Int64
        msgToJSQ?.id_local = id_local_db
        //let id_local = String(describing: id_local_db)
//        if is_send == false && time_now - write_time >= 4 {
//            msgToJSQ?.show_resend_btn = true
//            if let _ = sending_dic.index(where: { (element) -> Bool in
//                if element.key == String(id_local) {
//                    return true
//                }
//                return false
//            }){
//                msgToJSQ?.is_resending = true
//            }
//        }
        return msgToJSQ!
    }
    func scroll_ToBottom(){
        if self.messages.count > 0 {
            let lastItemIndex = IndexPath(row: self.messages.count-1, section: 0)
            self.collectionView.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.bottom, animated: false)
            self.loadHistorySwitch = true
        }
        
    }
    func dissmis_leybroad(){
        self.view.endEditing(true)
    }
    func add_tap(){
        let tap_event = UITapGestureRecognizer(target: self, action: #selector(self.dissmis_leybroad))
        self.view.addGestureRecognizer(tap_event)
        
    }
    func request_last_read_id_from_server_private(){
        if clientId != nil{
            let send_dic = [
                "client_id":clientId!
            ]
            HttpRequestCenter().request_user_data_v2("request_last_read_id_from_server_private", send_dic: send_dic as Dictionary<String, AnyObject>, InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                if return_dic != nil && !(return_dic?.isEmpty)!{
                    let last_id_server = return_dic!["last_id_server"] as! String
                    DispatchQueue.main.async {
                        sql_database.update_private_msg_read_with_server_id(id_server_ins: last_id_server)
                            self.update_database(mode: .change_read_state)
                    }
                    
                }
            })
        }
    }
    var aspectRatioConstraint: NSLayoutConstraint? {
        willSet {
            if let existingConstraint = aspectRatioConstraint {
                view.removeConstraint(existingConstraint)
            }
        }
        didSet {
            if let newConstraint = aspectRatioConstraint {
                view.addConstraint(newConstraint)
            }
        }
    }
    func reload_agter_2_sec(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.update_database(mode: .change_resend_btn)
        }
    }
    func reload_after_5_sec(){
        // 檢查未送出訊息
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { 
            self.update_database(mode: .change_resend_btn)
        }
    }
    func reset_sending_dic_after_5_sec(){
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.reset_sending_dic), userInfo: nil, repeats: false)
    }
    func reset_sending_dic(){
        let time_now = Int(Date().timeIntervalSince1970)
        for sending_dic_datas in sending_dic{
            if time_now - sending_dic_datas.value >= 4 {
                sending_dic.removeValue(forKey: sending_dic_datas.key)
            }
        }
    }
    func send_all_msg(){
        if let send_list = sql_database.get_unsend_private_data(client_id: clientId!){
            for send_data in send_list{
                sending_dic[send_data["id_local"] as! String] = Int(Date().timeIntervalSince1970)
                socket.write(data: json_dumps(send_data))
            }
        }
        update_database(mode: .change_resend_btn)
        reset_sending_dic_after_5_sec()
        reload_agter_2_sec()
        reload_after_5_sec()
    }
    
}

class JSQMessage3:JSQMessage{
    var topicId:String?  //來自server定義的id
    var topicTempid:String? //臨時自定義id
    var isRead:Bool?
    var show_resend_btn = false
    var is_resending = false
    var id_local:Int64?
}



// 如果下載歷史訊息一半斷線








