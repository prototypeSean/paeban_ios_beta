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
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func addRequestMission(missionType:String,data:AnyObject){
        let wsSendList = ["request_history_priv_msg","priv_msg","priv_msg_been_read"]
        
        if let _ = wsSendList.indexOf(missionType){
            var addDic:Dictionary<String,AnyObject> = [:]
            addDic["missionType"] = missionType
            addDic["data"] = data
            workList.append(addDic)
            executeWork(addDic)
        }
    }
    
    func executeWork(dataDic:Dictionary<String,AnyObject>){
        let missionType = dataDic["missionType"] as! String
        let wsSendList = ["request_history_priv_msg","priv_msg","priv_msg_been_read"]
        if let _ = wsSendList.indexOf(missionType){
            let sendData = dataDic["data"] as! NSDictionary
            socket.writeData(json_dumps(sendData))
        }
    }
    
    func removeWorkList(missionType:String,data:AnyObject?) {
        if missionType == "request_history_priv_msg"{
            if let _ = workList.indexOf({ (target) -> Bool in
                if target.first!.0 == "request_history_priv_msg"{
                    return true
                }
                else{return false}
            }){
                var newList:Array<Dictionary<String,AnyObject>> = []
                for workList_s in workList{
                    if workList_s.first!.0 != "request_history_priv_msg"{
                        newList.append(workList_s)
                    }
                }
                workList = newList
            }
        }
        else if missionType == "priv_msg"{
            if let removeDataIndex = workList.indexOf({ (target) -> Bool in
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
                workList.removeAtIndex(removeDataIndex)
            }
        }
        
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return CGFloat(20)
    }
    //MARK:顯示"已讀"
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if messages[indexPath.item].isRead == true{
            return NSAttributedString(string:"已讀")
        }
        else{
            return NSAttributedString(string:"")
        }
    }
    
    
    // 設定訊息顏色，用JSQ的套件
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.init(red:0.98, green:0.49, blue:0.29, alpha:1.0))
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "好友"
        setupBubbles()
        
        // 這兩個是初始化一定要有的參數
        //MARK:自己的參數
        senderId = setID
        senderDisplayName = setName
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        //      上面要留白多高
        //      self.topContentAdditionalInset = 90
        
        //wsActive.wasd_ForChatViewController = self
        let sendDic:NSDictionary = ["msg_type":"request_history_priv_msg",
                       "receiver_id":clientId!,
                       "last_id_of_msg":"0"]
        wsActive.wasd_ForFriendChatViewController = self
        addRequestMission("request_history_priv_msg",data: sendDic)
        
    }
    
    // 下面兩個負責讀取訊息
    // JSQ的列表顯示view, 在物件索引位至的訊息
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    // 此部份顯示物件的數量
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    // 藉由 indexPath 來判定要畫成收到還是送出的信息
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    // 原本套件在每個信息前面有照片，這邊把他取消
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage3(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    // MARK:滾動中
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -5 && loadHistorySwitch == true{
            loadHistorySwitch = false
            if let minMsgId = messages.first?.topicId{
                let sendDic:Dictionary = ["msg_type":"request_history_priv_msg",
                                          "receiver_id":clientId!,
                                          "last_id_of_msg":minMsgId]
                addRequestMission("request_history_priv_msg", data: sendDic)
            }
        }
    }
    
    
    //MARK:送出按鈕按下後
    override func didPressSendButton(button: UIButton?, withMessageText text: String?, senderId: String?, senderDisplayName: String?, date: NSDate?) {
        //送出WS訊息
        let timeNow = Int(NSDate().timeIntervalSince1970)
        let tempTopicMsgId = String(timeNow)
        let dataDic:NSDictionary = [
            "msg_type":"priv_msg",
            "msg":text!,
            "receiver":clientId!,
            "safe_code":"",
            "temp_priv_msg_id":tempTopicMsgId,
        ]
        let appendMsg = JSQMessage3(senderId: senderId, displayName: senderDisplayName, text: text)
        appendMsg.topicTempid = tempTopicMsgId
        self.messages.append(appendMsg)
        
        self.finishSendingMessageAnimated(true)
        self.collectionView?.reloadData()
        addRequestMission("priv_msg", data: dataDic)
    }
    // MARK:ws回傳信號
    func wsOnMsg(msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        if msgType == "priv_msg"{
            if (msg["sender_id"] as? String)! == userData.id!
                && (msg["receiver_id"] as? String)! == clientId{
                if let _ = messages.indexOf({ (msgTarget) -> Bool in
                    if msgTarget.topicTempid! == msg["temp_priv_msg_id"] as? String{
                        return true
                    }
                    else{return false}
                }){
                    if let msgIndex = messages.indexOf({ (target) -> Bool in
                        if target.topicTempid == msg["temp_priv_msg_id"] as? String{
                            return true
                        }
                        else{return false}
                    }){
                        messages[msgIndex].topicId = msg["msg_id"] as? String
                    }
                    
                    removeWorkList("priv_msg", data: msg)
                }
            }
            else if (msg["sender_id"] as? String)! == clientId
                && (msg["receiver_id"] as? String)! == userData.id!{
                // 別人說的
                let msgObj = JSQMessage3(senderId: msg["sender_id"] as! String,
                                         displayName: msg["sender_name"] as! String,
                                         text: msg["msg"] as! String)
                msgObj.isRead = false
                msgObj.topicId = msg["msg_id"] as? String
                msgObj.topicTempid = ""
                messages += [msgObj]
                self.collectionView.reloadData()
                scrollToBottom()
                //跟server說 已讀
                let sendData = ["msg_type":"priv_msg_been_read",
                                "msg_id":msg["msg_id"] as! String]
                var addDic:Dictionary<String,AnyObject> = [:]
                addDic["missionType"] = "priv_msg_been_read"
                addDic["data"] = sendData
                executeWork(addDic)
            }
        }
        else if msgType == "history_priv_msg"{
            var tempMsgList:Array<JSQMessage3> = []
            let history_msg_names_list = msg["history_msg_names_list"] as! Array<String>
            let history_msg_userid_list = msg["history_msg_userid_list"] as! Array<String>
            let history_msg_list = msg["history_msg_list"] as! Array<String>
            let history_msg_id_list = msg["history_msg_id_list"] as! Array<Int>
            let been_read_list = msg["been_read_list"] as! Array<String>
            for datasIndex in 0..<history_msg_names_list.count{
                var tempDic:Dictionary<String,AnyObject> = [:]
                tempDic["senderId"] = history_msg_userid_list[datasIndex]
                tempDic["displayName"] = history_msg_names_list[datasIndex]
                tempDic["text"] = history_msg_list[datasIndex]
                tempDic["topicId"] = String(history_msg_id_list[datasIndex])
                tempDic["topicTempid"] = ""
                if been_read_list[datasIndex] == "0" || history_msg_userid_list[datasIndex] != userData.id{
                    tempDic["isRead"] = false
                }
                else{
                    tempDic["isRead"] = true
                }
                tempMsgList.insert(FriendTableViewMedol().turnToMessage3(tempDic), atIndex: 0)
            }
            let msgCountBefore = messages.count
            self.messages = tempMsgList + self.messages
            self.collectionView?.reloadData()
            self.collectionView?.layoutIfNeeded()
            
            let msgCountAfte = messages.count
            
            // 滾輪位置校正
            if msgCountBefore <= 0{
                scrollToBottom()
                self.loadHistorySwitch = true
            }
            else{
                if msgCountAfte - msgCountBefore != 0{
                    self.loadHistorySwitch = true
                }
                let lastItemIndex = NSIndexPath(forRow: msgCountAfte - msgCountBefore, inSection: 0)
                self.collectionView.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
            }
            
            self.removeWorkList("request_history_priv_msg", data: nil)
            
        }
        else if msgType == "priv_msg_been_read"{
            let msgId = String(msg["msg_id"] as! Int)
            if let msgIndex = messages.indexOf({ (target) -> Bool in
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
            for workList_s in workList{
                executeWork(workList_s)
            }
        }
    }
    
    
    func updataNowTopicCellList(resultDic:Dictionary<String,AnyObject>){
        
        for resultDicData in resultDic{
            let resultDicDataVal = resultDicData.1 as! Dictionary<String,AnyObject>
            let topicId = resultDicDataVal["topic_id"] as! String
            if let nowTopicCellListIndex = nowTopicCellList.indexOf({ (target) -> Bool in
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
        let lastItemIndex = NSIndexPath(forRow: self.messages.count-1, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: false)
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








