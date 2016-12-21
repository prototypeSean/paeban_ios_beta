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
    var topicId:String?
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
        if messages[indexPath.item].isRead == true{
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
        super.viewWillAppear(animated)
        let sendDic:NSDictionary = ["msg_type":"request_history_priv_msg",
                                    "receiver_id":clientId!,
                                    "last_id_of_msg":"0"]
        wsActive.wasd_ForFriendChatViewController = self
        addRequestMission("request_history_priv_msg",data: sendDic)
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
        let timeNow = Int(Date().timeIntervalSince1970)
        let tempTopicMsgId = String(timeNow)
        let dataDic:NSDictionary = [
            "msg_type":"priv_msg",
            "msg":text!,
            "receiver":clientId!,
            "safe_code":"",
            "temp_priv_msg_id":tempTopicMsgId,
        ]
        let appendMsg = JSQMessage3(senderId: senderId, displayName: senderDisplayName, text: text)
        appendMsg?.topicTempid = tempTopicMsgId
        self.messages.append(appendMsg!)
        
        self.finishSendingMessage(animated: true)
        self.collectionView?.reloadData()
        addRequestMission("priv_msg", data: dataDic)
    }
    // MARK:ws回傳信號
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        if msgType == "priv_msg"{
            if (msg["sender_id"] as? String)! == userData.id!
                && (msg["receiver_id"] as? String)! == clientId{
                if let _ = messages.index(where: { (msgTarget) -> Bool in
                    if msgTarget.topicTempid! == msg["temp_priv_msg_id"] as? String{
                        return true
                    }
                    else{return false}
                }){
                    if let msgIndex = messages.index(where: { (target) -> Bool in
                        if target.topicTempid == msg["temp_priv_msg_id"] as? String{
                            return true
                        }
                        else{return false}
                    }){
                        messages[msgIndex].topicId = msg["msg_id"] as? String
                    }
                    
                    removeWorkList("priv_msg", data: msg as AnyObject?)
                }
            }
            else if (msg["sender_id"] as? String)! == clientId
                && (msg["receiver_id"] as? String)! == userData.id!{
                // 別人說的
                let msgObj = JSQMessage3(senderId: msg["sender_id"] as! String,
                                         displayName: msg["sender_name"] as! String,
                                         text: msg["msg"] as! String)
                msgObj?.isRead = false
                msgObj?.topicId = msg["msg_id"] as? String
                msgObj?.topicTempid = ""
                self.messages += [msgObj!]
                self.collectionView.reloadData()
                scrollToBottom()
                //跟server說 已讀
                let sendData = ["msg_type":"priv_msg_been_read",
                                "msg_id":msg["msg_id"] as! String]
                var addDic:Dictionary<String,AnyObject> = [:]
                addDic["missionType"] = "priv_msg_been_read" as AnyObject?
                addDic["data"] = sendData as AnyObject?
                executeWork(addDic)
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
            let msgId = String(msg["msg_id"] as! Int)
            if let msgIndex = messages.index(where: { (target) -> Bool in
                if target.topicId == msgId{
                    return true
                }
                else{return false}
            }){
                messages[msgIndex].isRead = true
                self.collectionView.reloadData()
            }
            
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








