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

    var messages = [JSQMessage3]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var setID:String? = "anonymous"
    var setName:String? = "anonymous"
    var clientId:String?
    var clientName:String?
    var loadHistorySwitch = false
    var workList:Array<Dictionary<String,AnyObject>> = []
    
    
    
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
            print("last_id_of_msg:\(sendData["last_id_of_msg"])")
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
            with: UIColor.jsq_messageBubbleLightGray())
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
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        //      上面要留白多高
        //      self.topContentAdditionalInset = 90
        
        //wsActive.wasd_ForChatViewController = self
    }
    override func viewWillAppear(_ animated: Bool) {
        messages = new_data()
        self.collectionView.reloadData()
        self.scroll(to: IndexPath(row: self.messages.count, section: 0), animated: false)
        DispatchQueue.global(qos: .background).async {
            usleep(50)
            DispatchQueue.main.async {
                self.scroll(to: IndexPath(row: self.messages.count, section: 0), animated: false)
                self.get_history_new_from_server()
            }
        }

        wsActive.wasd_ForFriendChatViewController = self
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.dismiss(animated: false, completion: nil)
        wsActive.wasd_ForFriendChatViewController = nil
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
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[(indexPath as NSIndexPath).item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.white
        } else {
            cell.textView!.textColor = UIColor.black
        }
        
        return cell
    }
    
    
    
    func addMessage(_ id: String, text: String) {
        let message = JSQMessage3(senderId: id, displayName: "", text: text)
        messages.append(message!)
    }
    // MARK:滾動中
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(self.collectionView.contentOffset.y)
        if scrollView.contentOffset.y <= -5 && loadHistorySwitch == true{
            loadHistorySwitch = false
            if let minMsgId = messages.first?.topicId{
                let sendDic:Dictionary = ["msg_type":"request_history_priv_msg",
                                          "receiver_id":clientId!,
                                          "last_id_of_msg":minMsgId]
                //print("add")
                addRequestMission("request_history_priv_msg", data: sendDic as AnyObject)
            }
        }
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
            "receiver":clientId! as AnyObject,
            "temp_priv_msg_id":tempTopicMsgId as AnyObject,
            "sender":userData.id! as AnyObject,
            "is_read":false as AnyObject,
            "is_send":false as AnyObject
        ]
        sql_database.inser_date_to_private_msg(input_dic: dataDic)
        sql_database.print_all2()
        self.update_database()
        if let send_list = sql_database.get_unsend_private_data(client_id: clientId!){
            for send_data in send_list{
                socket.write(data: json_dumps(send_data))
            }
        }
        
        
        
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
        
        if msgType == "priv_msg"{
            let resultDic_msg_id:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary<String,AnyObject>
            for resultDic in resultDic_msg_id.values{
                if (resultDic["sender_id"] as? String)! == userData.id!
                    && (resultDic["receiver_id"] as? String)! == clientId{

                    let id_local = resultDic["id_local"] as! String
                    let time_input = resultDic["time"] as! String
                    let id_server_input = resultDic["id_server"] as! String
                    sql_database.update_private_msg_time(id_local: id_local, time_input: time_input, id_server_input: id_server_input)
                    //update_database()
                    //                if let _ = messages.index(where: { (msgTarget) -> Bool in
                    //                    if msgTarget.topicTempid! == msg["temp_priv_msg_id"] as? String{
                    //                        return true
                    //                    }
                    //                    else{return false}
                    //                }){
                    //                    if let msgIndex = messages.index(where: { (target) -> Bool in
                    //                        if target.topicTempid == msg["temp_priv_msg_id"] as? String{
                    //                            return true
                    //                        }
                    //                        else{return false}
                    //                    }){
                    //                        messages[msgIndex].topicId = msg["msg_id"] as? String
                    //                    }
                    //
                    //                    removeWorkList("priv_msg", data: msg as AnyObject?)
                    //                }
                    
                }
                else if (resultDic["sender_id"] as? String)! == clientId
                    && (resultDic["receiver_id"] as? String)! == userData.id!{
                    self.get_history_new_from_server()
                    
                    // 別人說的
                    //                let msgObj = JSQMessage3(senderId: msg["sender_id"] as! String,
                    //                                         displayName: msg["sender_name"] as! String,
                    //                                         text: msg["msg"] as! String)
                    //                msgObj?.isRead = false
                    //                msgObj?.topicId = msg["msg_id"] as? String
                    //                msgObj?.topicTempid = ""
                    //                self.messages += [msgObj!]
                    //                self.collectionView.reloadData()
                    //                scrollToBottom()
                    //跟server說 已讀
                    let sendData = ["msg_type":"priv_msg_been_read",
                                    "msg_id":resultDic["id_server"] as! String]
                    var addDic:Dictionary<String,AnyObject> = [:]
                    addDic["missionType"] = "priv_msg_been_read" as AnyObject?
                    addDic["data"] = sendData as AnyObject?
                    executeWork(addDic)
                }
            }
            
        }
        else if msgType == "history_priv_msg"{
            func turnToMessage3(_ inputDic:Dictionary<String,AnyObject>) -> JSQMessage3{
                let returnObj = JSQMessage3(senderId: inputDic["senderId"] as! String,
                                            displayName: inputDic["displayName"] as! String,
                                            text: inputDic["text"] as! String)
                returnObj?.topicId = inputDic["topicId"] as? String
                returnObj?.topicTempid = inputDic["topicTempid"] as? String
                returnObj?.isRead = inputDic["isRead"] as? Bool
                return returnObj!
            }
            self.removeWorkList("request_history_priv_msg", data: nil)
            var tempMsgList:Array<JSQMessage3> = []
            let history_msg_names_list = msg["history_msg_names_list"] as! Array<String>
            let history_msg_userid_list = msg["history_msg_userid_list"] as! Array<String>
            let history_msg_list = msg["history_msg_list"] as! Array<String>
            let history_msg_id_list = msg["history_msg_id_list"] as! Array<Int>
            let been_read_list = msg["been_read_list"] as! Array<String>
            for datasIndex in 0..<history_msg_names_list.count{
                var tempDic:Dictionary<String,AnyObject> = [:]
                tempDic["senderId"] = history_msg_userid_list[datasIndex] as AnyObject?
                tempDic["displayName"] = history_msg_names_list[datasIndex] as AnyObject?
                tempDic["text"] = history_msg_list[datasIndex] as AnyObject?
                tempDic["topicId"] = String(history_msg_id_list[datasIndex]) as AnyObject?
                tempDic["topicTempid"] = "" as AnyObject?
                if been_read_list[datasIndex] == "0" || history_msg_userid_list[datasIndex] != userData.id{
                    tempDic["isRead"] = false as AnyObject?
                }
                else{
                    tempDic["isRead"] = true as AnyObject?
                }
                tempMsgList.insert(turnToMessage3(tempDic), at: 0)
            }
            let msgCountBefore = messages.count
            self.messages = tempMsgList + self.messages
            self.collectionView?.reloadData()
            self.collectionView?.layoutIfNeeded()
            
            let msgCountAfte = messages.count
            
            // 滾輪位置校正
            if msgCountBefore <= 0{
                scrollToBottom()
                //self.loadHistorySwitch = true
            }
            else{
                let lastItemIndex = IndexPath(row: msgCountAfte - msgCountBefore, section: 0)
                self.collectionView.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: false)
                
                if msgCountAfte - msgCountBefore != 0{
                    self.loadHistorySwitch = true
                }
            }
            
            
            
        }
        else if msgType == "priv_msg_been_read"{
            //let msgId = String(msg["msg_id"] as! Int)
            let id_loacal = msg["id_local"] as! String
            sql_database.update_private_msg_read(id_local: id_loacal)
            update_database()
            
            
//            if let msgIndex = messages.index(where: { (target) -> Bool in
//                if target.topicId == msgId{
//                    return true
//                }
//                else{return false}
//            }){
//                messages[msgIndex].isRead = true
//                self.collectionView.reloadData()
//            }
            
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
            print("======\(workList.count)=====")
            for workList_s in workList{
                executeWork(workList_s)
            }
        }
    }
    func get_history_new_from_server(){
        let last_id_server:String = sql_database.get_private_msg_last_id_server(client_id_input:clientId!)
        
        var init_sql_state = "0"
        if init_sql{
            init_sql_state = "1"
            init_sql = false
        }
        let request_dic:Dictionary<String,String> = [
            "last_id_server":last_id_server,
            "client_id":clientId!,
            "init_sql":init_sql_state
        ]
        HttpRequestCenter().request_user_data("history_private_msg_new", send_dic: request_dic) { (return_dic) in
            if return_dic["result"] as! String == "not_exist"{
                //close window
            }
            else if return_dic["result"] as! String == "no_new_data"{
                DispatchQueue.main.async {
                    self.update_database()
                }
            }
            else if return_dic["result"] as! String == "success"{
                let data_list:Array<Dictionary<String,AnyObject>> = return_dic["data_list"]! as! Array<Dictionary<String, AnyObject>>
                
                for data in data_list{
                    sql_database.inser_date_to_private_msg(input_dic: data)
                }
                DispatchQueue.main.async {
                    self.update_database()
                }
            }
            
        }
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
    func update_database(){
        messages = new_data()
        self.collectionView.reloadData()
        self.scroll(to: IndexPath(row: messages.count, section: 0), animated: true)
    }
    func new_data() -> Array<JSQMessage3>{
        var new_message_list:Array<JSQMessage3> = []
        let data_dic = sql_database.get_private_histopry_msg(client_id: clientId!)
        for data_s in data_dic{
            new_message_list.append(make_JSQMessage3(input_dic: data_s))
        }
        return new_message_list
    }
    func make_JSQMessage3(input_dic:Dictionary<String,AnyObject>) -> JSQMessage3{
        let msgToJSQ = JSQMessage3(senderId: input_dic["sender"] as? String, displayName: "non", text: input_dic["private_text"] as? String)
        msgToJSQ?.isRead = input_dic["is_read"] as? Bool
        return msgToJSQ!
    }
    func scrollToBottom(){
        if self.messages.count > 0 {
            let lastItemIndex = IndexPath(row: self.messages.count-1, section: 0)
            self.collectionView.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.bottom, animated: false)
            self.loadHistorySwitch = true
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
    
}

class JSQMessage3:JSQMessage{
    var topicId:String?  //來自server定義的id
    var topicTempid:String? //臨時自定義id
    var isRead:Bool?
}



// 如果下載歷史訊息一半斷線








