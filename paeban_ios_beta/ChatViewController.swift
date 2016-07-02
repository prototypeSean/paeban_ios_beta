//
//  TopicViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved. 
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController,webSocketActiveCenterDelegate {
    @IBOutlet weak var topicTitle: UILabelPadding!
    
        // MARK: Properties
    var messages = [JSQMessage2]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var setID:String? = "anonymous"
    var setName:String? = "anonymous"
    var topicId:String?
    var ownerId:String?
    
    
    var historyMsg:Dictionary<String,AnyObject>{
        get{return [:]}
        set{
            var tempMsgList = [JSQMessage2]()
            for msg_s in newValue{
//                read = 1;
//                receiver = "\U674e\U7b56\U58eb";
//                sender = "\U9ad8\U5929\U627f";
//                text = "\U518d\U4f86";
                let sender = msg_s.1["sender"] as! String
                let text = msg_s.1["text"] as! String
                let tempMsg_s = JSQMessage2(senderId: sender, displayName: "anonymous", text: text)
                tempMsg_s.topicContentId = msg_s.0
                tempMsgList += [tempMsg_s]
            }
            let retureList = tempMsgList.sort { (msg0, msg1) -> Bool in
                let msg0Int = Int(msg0.topicContentId!)
                let msg1Int = Int(msg1.topicContentId!)
                return msg0Int < msg1Int
            }
            if self.messages.isEmpty{
                self.messages = retureList
            }
            else{
                self.messages = retureList + self.messages
            }
            self.finishSendingMessageAnimated(true)
            self.collectionView?.reloadData()
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
        title = "話題"
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
        wsActive.wasd_ForChatViewController = self
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
    
    
    // asks the data source for the message bubble image data that corresponds to the message data item at indexPath in the collectionView. This is exactly where you set the bubble’s image.
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
        let message = JSQMessage2(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    
    //MARK:送出按鈕按下後
    override func didPressSendButton(button: UIButton?, withMessageText text: String?, senderId: String?, senderDisplayName: String?, date: NSDate?) {
        //送出WS訊息
        let tempTopicMsgId = String(NSDate().timeIntervalSince1970)
        let dataDic:NSDictionary = [
            "msg_type":"topic_msg",
            "msg":text!,
            "receiver":ownerId!,
            "temp_topic_msg_id":tempTopicMsgId,
            "topic_id":topicId!
        ]
        let sendData = json_dumps(dataDic)
        socket.writeData(sendData)
        
        
        
        self.messages.append(JSQMessage2(senderId: senderId, displayName: senderDisplayName, text: text))
        self.finishSendingMessageAnimated(true)
        self.collectionView?.reloadData()
    }
    
    func wsOnMsg(msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        if msgType == "topic_msg"{
            let resultDic:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary
            for dicKey in resultDic{
                let msgData = dicKey.1 as! Dictionary<String,AnyObject>
                if msgData["sender"] as? String == setID{
                    //移除送出中的符號
                    print("自己說話回傳確認")
                }
                else{
                    print(msgData)
                    let msgToJSQ = JSQMessage2(senderId: msgData["sender"] as? String, displayName: "non", text: msgData["topic_content"] as? String)
                    messages += [msgToJSQ]
                    self.finishSendingMessageAnimated(true)
                    self.collectionView?.reloadData()
                }
            }
            //let msgPack = JSQMessage2(senderId: <#T##String!#>, displayName: <#T##String!#>, text: <#T##String!#>)
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
class JSQMessage2:JSQMessage{
    var topicContentId:String?  //來自server定義的id
    var topicTempid:String? //臨時自定義id
    //16 118  127
}

//未送訊息解法，在每一訊息上綁定click功能，在Ｊmsg屬性裡自訂未讀狀態：Ｂool
//並利用uincode寫入驚嘆號及“未送出”字樣




