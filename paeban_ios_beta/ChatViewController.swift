//
//  TopicViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    @IBOutlet weak var topicTitle: UILabelPadding!
    
        // MARK: Properties
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var setID:String? = "anyone"
    var setName:String? = "anyone"
    
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
        
        
        
        //MARK:飛行前移除
        if senderId == "anyone"{
            print("id尚未設定成功")
        }
        else{
            print(senderId)
        }
        //MARK:飛行前移除
        
        
        
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
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    
    //MARK:送出按鈕按下後
    override func didPressSendButton(button: UIButton?, withMessageText text: String?, senderId: String?, senderDisplayName: String?, date: NSDate?) {
        
        
        self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        self.finishSendingMessageAnimated(true)
        self.collectionView?.reloadData()
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

//未送訊息解法，在每一訊息上綁定click功能，在Ｊmsg屬性裡自訂未讀狀態：Ｂool
//並利用uincode寫入驚嘆號及“未送出”字樣
