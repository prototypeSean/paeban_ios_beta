//
//  TopicViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved. 
//

import UIKit
import JSQMessagesViewController
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ChatViewController: JSQMessagesViewController,webSocketActiveCenterDelegate {
    @IBOutlet weak var topicTitle: UILabelPadding!
    
        // MARK: Properties
    var messages = [JSQMessage2]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var setID:String? = "anonymous"
    var setName:String? = "anonymous"
    var clientID:String?
    var clientName:String?
    var topicId:String?
    var ownerId:String?
    
    //collectionView(_:attributedTextForMessageBubbleTopLabelAtIndexPath:)
    //MARK:讀入歷史訊息
    var historyMsg:Dictionary<String,AnyObject>{
        get{return [:]}
        set{
//            var tempMsgList = [JSQMessage2]()
//            for msg_s in newValue{
//                let sender = msg_s.1["sender"] as! String
//                let text = msg_s.1["text"] as! String
//                let tempMsg_s = JSQMessage2(senderId: sender, displayName: "anonymous", text: text)
//                tempMsg_s?.topicContentId = msg_s.0
//                if sender == setID && msg_s.1["read"] as! Bool == true{
//                    tempMsg_s?.isRead = true
//                }
//                tempMsgList += [tempMsg_s!]
//            }
//            let retureList = tempMsgList.sorted { (msg0, msg1) -> Bool in
//                let msg0Int = Int(msg0.topicContentId!)
//                let msg1Int = Int(msg1.topicContentId!)
//                return msg0Int < msg1Int
//            }
//            if self.messages.isEmpty{
//                self.messages = retureList
//            }
//            else{
//                self.messages = retureList + self.messages
//            }
//            self.finishSendingMessage(animated: true)
//            self.collectionView?.reloadData()
        }
    }
    var topicNotExist:String?{
        get{return ""}
        set{
            //navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return CGFloat(20)
    }
    //MARK: 顯示"已讀"
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if messages[indexPath.item].isRead == true{
            return NSAttributedString(string:"已讀"+" ")
        }
        else{
            return NSAttributedString(string:"")
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.dismiss(animated: false, completion: nil)
        wsActive.wasd_ForChatViewController = nil
    }
    
    // MARK: 設定訊息顏色，用JSQ的套件
    fileprivate func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(
            with: UIColor(red:0.97, green:0.49, blue:0.31, alpha:1.0))
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(
            with: UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "話題"
        setupBubbles()
        //移除迴紋針按鈕
        self.inputToolbar.contentView.leftBarButtonItem = nil
        // 這兩個是初始化一定要有的參數
        //MARK:自己的參數
        senderId = setID
        senderDisplayName = setName
        dennis_kao_s_fucking_trash()
    }
    override func viewWillAppear(_ animated: Bool) {
        update_database()
        if !renew_data().isEmpty{
            get_history_old()
        }
        get_history_new()
        
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
    
    
    // asks the data source for the message bubble image data that corresponds to the message data item at indexPath in the collectionView. This is exactly where you set the bubble’s image.
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
        
        if message.senderId == senderId {
            
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
                as! CustomMessagesCollectionViewCellOutgoing
            
            cell.textView!.textColor = UIColor.white
            cell.reloadBTN!.textColor = UIColor.blue
            
            
            return cell
        }
            
        else {
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
                as! CustomMessagesCollectionViewCellIncoming
            
            cell.textView!.textColor = UIColor.white
            
            return cell
        }
    }
    func addMessage(_ id: String, text: String) {
        let message = JSQMessage2(senderId: id, displayName: "", text: text)
        messages.append(message!)
    }
    func renew_data() -> Array<JSQMessage2>{
        var new_message_list:Array<JSQMessage2> = []
        let data_dic = sql_database.get_histopry_msg(topic_id_input: topicId!, client_id: clientID!)
        for data_s in data_dic{
            new_message_list.append(make_JSQMessage2(input_dic: data_s))
        }
        return new_message_list
    }
    
    //MARK:送出按鈕按下後
    override func didPressSend(_ button: UIButton?, withMessageText text: String?, senderId: String?, senderDisplayName: String?, date: Date?) {
        //送出WS訊息
        self.finishSendingMessage(animated: true)
        let timeNow = Int(Date().timeIntervalSince1970)
        let tempTopicMsgId = String(timeNow)
        let dataDic:Dictionary<String, AnyObject> = [
            "msg_type":"topic_msg" as AnyObject,
            "topic_content":text! as AnyObject,
            "receiver":ownerId! as AnyObject,
            "temp_topic_msg_id":tempTopicMsgId as AnyObject,
            "topic_id":topicId! as AnyObject,
            "sender":userData.id! as AnyObject,
            "is_read":false as AnyObject,
            "is_send":false as AnyObject
        ]
        sql_database.inser_date_to_topic_content(input_dic: dataDic)
        
        let unsend_list = sql_database.get_unsend_topic_data(topic_id_input: topicId!, client_id: ownerId!)
        for unsend_list_s in unsend_list!{
            //print(unsend_list_s)
            //let yyy = json_dumps(unsend_list_s)
            socket.write(data: json_dumps(unsend_list_s))
        }
        
        let data_dic = sql_database.get_histopry_msg(topic_id_input: topicId!, client_id: clientID!)
        var new_message_list:Array<JSQMessage2> = []
        for data_s in data_dic{
            new_message_list.append(make_JSQMessage2(input_dic: data_s))
        }
        messages = new_message_list
        
        self.collectionView?.reloadData()
        
        self.scroll(to: IndexPath(row: messages.count, section: 0), animated: true)
//        let appendMsg = JSQMessage2(senderId: senderId, displayName: senderDisplayName, text: text)
//        appendMsg?.topicTempid = tempTopicMsgId
//        self.messages.append(appendMsg!)
//
//        self.finishSendingMessage(animated: true)
//        self.collectionView?.reloadData()
//        let sendData = json_dumps(dataDic)
//        socket.write(data:sendData)
    }
    //MARK:ws回傳信號
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        if msgType == "topic_msg"{
            let resultDic:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary
            updataNowTopicCellList(resultDic)
            for dicKey in resultDic{
                let msgData = dicKey.1 as! Dictionary<String,AnyObject>
                if setID != nil && topicId != nil && clientID != nil{
                    
                    if msgData["sender"] as? String == setID && msgData["topic_id"] as? String == topicId{
                        //自己說的話
                        //可插入“移除送出中的符號”的code
                        //print(msg)
                        // 施工中
                        let id_local = msgData["id_local"] as! String
                        let time_input = msgData["time"] as! String
                        let id_server_input = msgData["id_server"] as! String
                        sql_database.update_topic_content_time(id_local: id_local, time_input: time_input, id_server_input:id_server_input)
                        // 施工中
                        
//                        let temp_topic_msg_id = msgData["temp_topic_msg_id"] as! String
//                        let findElement = messages.index(where: { (target) -> Bool in
//                            if target.topicTempid == temp_topic_msg_id{
//                                return true
//                            }
//                            else{return false}
//                        })
//                        if let targetPosition = findElement{
//                            messages[targetPosition].topicContentId = dicKey.0
//                        }
                        
                    }
                    else if msgData["receiver"] as? String == setID && msgData["sender"] as? String == clientID{
                        //別人說的話
                        //topic_content_read
                        //topic_content_id
                        
                        // 施工中
                        get_history_new()
//                        sql_database.inser_date_to_topic_content(input_dic: msgData)
//                        messages = renew_data()
//                        
//                        let sendData2 = [
//                            "msg_type":"topic_content_read",
//                            "topic_content_id":dicKey.0
//                        ]
//                        socket.write(data:json_dumps(sendData2 as NSDictionary))
//                        
//                        self.collectionView?.reloadData()
//                        
//                        self.scroll(to: IndexPath(row: messages.count, section: 0), animated: true)
                        // 施工中
                        
//                        let msgToJSQ = JSQMessage2(senderId: msgData["sender"] as? String, displayName: "non", text: msgData["topic_content"] as? String)
//                        msgToJSQ?.topicContentId = dicKey.0
//                        messages += [msgToJSQ!]
//                        
//                        let sendData = [
//                            "msg_type":"topic_content_read",
//                            "topic_content_id":dicKey.0
//                        ]
//                        socket.write(data:json_dumps(sendData as NSDictionary))
//                        //self.finishSendingMessage(animated: true)
//                        self.collectionView?.reloadData()
//                        
//                        self.scroll(to: IndexPath(row: messages.count, section: 0), animated: true)
                    }
                }
                
            }
            
        }
        else if msgType == "topic_content_been_read"{
            //let topicContentId = msg["topic_content_id"] as! String
            
            // 施工中
            let id_local_input = msg["id_local"] as! String
            sql_database.update_topic_content_read(id_local: id_local_input)
            let data = sql_database.get_histopry_msg(topic_id_input: topicId!, client_id: clientID!)
            var new_list:Array<JSQMessage2> = []
            for data_s in data{
                new_list.append(make_JSQMessage2(input_dic: data_s))
            }
            messages = new_list
            self.collectionView.reloadData()
            self.scroll(to: IndexPath(row: messages.count, section: 0), animated: true)
            // 施工中
//            let topicContentPosition = messages.index(where: { (target) -> Bool in
//                let targetId = target.topicContentId
//                if targetId == topicContentId{
//                    return true
//                }
//                else{
//                    return false
//                }
//            })
//            if topicContentPosition != nil{
//                messages[topicContentPosition!].isRead = true
//                //print("xxx")
//                self.collectionView?.reloadData()
//            }
            
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
        messages = renew_data()
        self.collectionView.reloadData()
        self.scroll(to: IndexPath(row: messages.count, section: 0), animated: true)
    }
    func get_history_new(){
        let last_id_server:String = sql_database.get_topic_content_last_id_server(topic_id_input: topicId!, client_id_input: clientID!)
        let request_dic:Dictionary<String,String> = [
            "last_id_server":last_id_server,
            "client_id":clientID!,
            "topic_id":topicId!
        ]
        HttpRequestCenter().request_user_data("history_topic_msg_new", send_dic: request_dic) { (return_dic) in
            if return_dic["result"] as! String == "not_exist"{
                
            }
            else if return_dic["result"] as! String == "no_new_data"{
                DispatchQueue.main.async {
                    self.update_database()
                }
            }
            else if return_dic["result"] as! String == "success"{
                let data_list:Array<Dictionary<String,AnyObject>> = return_dic["data_list"]! as! Array<Dictionary<String, AnyObject>>
                
                for data in data_list{
                    sql_database.inser_date_to_topic_content(input_dic: data)
                }
                DispatchQueue.main.async {
                    self.update_database()
                }
            }
            
        }
    }
    func get_history_old(){
        let first_id_server:String = sql_database.get_topic_content_first_id_server(topic_id_input: topicId!, client_id_input: clientID!)
        let request_dic:Dictionary<String,String> = [
            "first_id_server":first_id_server,
            "client_id":clientID!,
            "topic_id":topicId!
        ]
        HttpRequestCenter().request_user_data("history_topic_msg_old", send_dic: request_dic) { (return_dic) in
            if return_dic["result"] as! String == "not_exist"{
                
            }
            else if return_dic["result"] as! String == "no_new_data"{
                DispatchQueue.main.async {
                    self.update_database()
                }
            }
            else if return_dic["result"] as! String == "success"{
                let data_list:Array<Dictionary<String,AnyObject>> = return_dic["data_list"]! as! Array<Dictionary<String, AnyObject>>
                for data in data_list{
                    sql_database.inser_date_to_topic_content(input_dic: data)
                }
                DispatchQueue.main.async {
                    self.update_database()
                }
            }
            
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
    func dennis_kao_s_fucking_trash(){
        // No avatars
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        //      上面要留白多高
        //      self.topContentAdditionalInset = 90
        wsActive.wasd_ForChatViewController = self
        
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
}
func make_JSQMessage2(input_dic:Dictionary<String,AnyObject>) -> JSQMessage2{
    let msgToJSQ = JSQMessage2(senderId: input_dic["sender"] as? String, displayName: "non", text: input_dic["topic_content"] as? String)
    msgToJSQ?.isRead = input_dic["is_read"] as? Bool
    return msgToJSQ!
}

class JSQMessage2:JSQMessage{
    var topicContentId:String?  //來自server定義的id
    var topicTempid:String? //臨時自定義id
    var isRead:Bool?
    //16 118  127
}



//未送訊息解法，在每一訊息上綁定click功能，在Ｊmsg屬性裡自訂未讀狀態：Ｂool
//並利用uincode寫入驚嘆號及“未送出”字樣




