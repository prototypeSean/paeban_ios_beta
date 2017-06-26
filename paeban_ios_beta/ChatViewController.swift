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
    var model:MyTopicTableViewModel?
    var sending_dic:Dictionary<String,Int> = [:]
    var topic_title_var:String?
    var tags:String?
    
    //collectionView(_:attributedTextForMessageBubbleTopLabelAtIndexPath:)
    //MARK:讀入歷史訊息
//    var historyMsg:Dictionary<String,AnyObject>{
//        get{return [:]}
//        set{
//
//        }
//    }
    var topicNotExist:String?{
        get{return ""}
        set{
            //navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: override
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return CGFloat(20)
    }
        // 顯示"已讀"
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if messages[indexPath.item].isRead == true && messages[indexPath.item].senderId == userData.id{
            return NSAttributedString(string:"已讀"+" ")
        }
        else{
            return NSAttributedString(string:"")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        super.viewWillAppear(animated)
        wsActive.wasd_ForChatViewController = self
        add_tap()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        update_database()
        update_topic_content_from_server(delegate_target_list:[wsActive.wasd_ForChatViewController])
        
    }

        // 下面兩個負責讀取訊息
        // JSQ的列表顯示view, 在物件索引位至的訊息
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
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
        
        if message.senderId == senderId {
            
            // 重新傳送的按鈕一定要用 CustomMessagesCollectionViewCellOutgoing
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
                as! CustomMessagesCollectionViewCellOutgoing
            cell.textView.textColor = UIColor.white
            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
            cell.reloadBtnContainer.backgroundColor = UIColor(red:0.99, green:0.38, blue:0.27, alpha:1.0)
            cell.reloadBtnContainer.isHidden = true
            func hideResendBtn_ins(){
                self.hideResendBtn(reSendContainer: cell.reloadBtnContainer, reSendingText: cell.resendingText)
            }
            func showResendBtn_ins(){
                self.showResendBtn(
                    reSendContainer: cell.reloadBtnContainer,
                    reSendBtn: cell.reloadBTN,
                    reSending: cell.reSending,
                    reSendingText: cell.resendingText
                )
            }
            func showResending_ins(){
                self.showResending(
                    reSendContainer: cell.reloadBtnContainer,
                    reSendBtn: cell.reloadBTN,
                    reSending: cell.reSending,
                    reSendingText: cell.resendingText
                )
            }
            

            let tap_event = UITapGestureRecognizer(target: self, action: #selector(self.dismiss_keybroad))
            cell.addGestureRecognizer(tap_event)
            if message.show_resend_btn == true {
                if message.is_resending == true {
                    showResending_ins()
                }
                else{
                    showResendBtn_ins()
                }
            }
            else{
                hideResendBtn_ins()
            }
            cell.chat_view_controller = self
            return cell
        }
            
        else {
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
                as! CustomMessagesCollectionViewCellIncoming
            cell.textView.textColor = UIColor.white
            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
            let tap_event = UITapGestureRecognizer(target: self, action: #selector(self.dismiss_keybroad))
            cell.addGestureRecognizer(tap_event)
            return cell
        }
    }
    
    // MARK: 控制失敗重傳按鈕
    func hideResendBtn(reSendContainer:UIView,reSendingText:UILabel){
        reSendContainer.isHidden = true
        reSendingText.isHidden = true
    }
    
    func showResendBtn(reSendContainer:UIView,reSendBtn:UIButton,reSending:UIActivityIndicatorView,reSendingText:UILabel){
        reSendContainer.isHidden = false
        reSendBtn.isHidden = false
        reSending.stopAnimating()
        reSendingText.isHidden = true
    }
    
    func showResending(reSendContainer:UIView,reSendBtn:UIButton,reSending:UIActivityIndicatorView,reSendingText:UILabel){
        reSendContainer.isHidden = false
        reSendBtn.isHidden = true
        reSending.startAnimating()
        reSendingText.isHidden = false
    }
    
    
//    func showResending(reSending:UIActivityIndicatorView) {
//        reSending.isHidden = false
//    }
    func dismiss_keybroad(){
        self.view.endEditing(true)
    }
    func add_tap(){
        let tap_event = UITapGestureRecognizer(target: self, action: #selector(self.dismiss_keybroad))
        self.view.addGestureRecognizer(tap_event)
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
    func check_new_msg_to_read(check_list:Array<Dictionary<String, AnyObject>>){
        let sort_list:Array<Dictionary<String, AnyObject>> = check_list.reversed()
        for datas in sort_list{
            if datas["sender"] as! String != userData.id!{
                if datas["is_read"] as! Bool == false{
                    // 寄送已讀  通知對方確認
                }
            }
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString!{
        return NSAttributedString(string:"test========================")
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return NSAttributedString(string:"test========================")
    }
    func get_battery() -> Int?{
        if model != nil{
            for cells in model!.mytopic{
                if cells.dataType == "title" && cells.topicId_title == topicId{
                    let unredMsg = Float(cells.unReadMsg_title)
                    let allMsg = Float(cells.allMsg_title)
                    let readRate = Int((1-(unredMsg/allMsg))*100)
                    return readRate
                }
                break
            }
        }
        return nil
    }
    
    
    //MARK:送出按鈕按下後
    override func didPressSend(_ button: UIButton?, withMessageText text: String?, senderId: String?, senderDisplayName: String?, date: Date?) {
        //送出WS訊息
        self.finishSendingMessage(animated: true)
        let timeNow = Int(Date().timeIntervalSince1970)
        let tempTopicMsgId = String(timeNow)
        var battery_val = -1
        if self.get_battery() != nil{
            battery_val = self.get_battery()!
        }
        let dataDic:Dictionary<String, AnyObject> = [
            "msg_type":"topic_msg" as AnyObject,
            "topic_content":text! as AnyObject,
            "receiver":ownerId! as AnyObject,
            "temp_topic_msg_id":tempTopicMsgId as AnyObject,
            "topic_id":topicId! as AnyObject,
            "sender":userData.id! as AnyObject,
            "is_read":false as AnyObject,
            "is_send":false as AnyObject,
            "battery": String(battery_val) as AnyObject
        ]
        //sql_database.inser_date_to_topic_content(input_dic: dataDic)
        sql_database.insert_self_topic_content(input_dic: dataDic, option: .new_msg)
        if !sql_database.check_is_in_mytopic(check_topic_id: topicId!){
            let insert_dic = [
                "topic_title": topic_title_var!,
                "topic_id": topicId!,
                "client_id": clientID!,
                "tags":tags
            ]
            sql_database.insert_recent_topic(input_dic: insert_dic)
        }
        //sql_database.delete_ignore_list(topic_id_ins: topicId!)
        send_all_msg()
    }
    // websocket delegate
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        if msgType == "topic_msg" && false{
            // 代碼移到web socket center運行
//            let resultDic:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary
//            updataNowTopicCellList(resultDic)
//            if setID != nil && topicId != nil && clientID != nil{
//                if resultDic["sender"] as? String == setID && resultDic["receiver"] as? String == clientID && resultDic["topic_id"] as? String == topicId{
//                    //自己說的話
//                    //可插入“移除送出中的符號”的code
//                    let id_local = resultDic["id_local"] as! String
//
//                    sql_database.insert_self_topic_content(input_dic: resultDic, option: .sended)
//                    sending_dic.removeValue(forKey: id_local)
//                    self.update_database()
//                }
//                else if resultDic["receiver"] as? String == setID && resultDic["sender"] as? String == clientID && resultDic["topic_id"] as? String == topicId{
//                    //別人說的話
//                    get_history_new()
//                    let sendData = [
//                        "msg_type":"topic_content_read",
//                        "topic_content_id":resultDic["id_server"] as! String
//                    ]
//                    socket.write(data:json_dumps(sendData as NSDictionary))
//                    
//                }
//            }
            
        }
        else if msgType == "topic_content_been_read"{
            let id_local_input = msg["id_local"] as! String
            print("topic_content_been_read \(id_local_input)")
            sql_database.update_topic_content_read(id_local: id_local_input)
            update_database()
        }
        else if msgType == "enter_topic"{
            let topic_id_input = msg["topic_id"] as! String
            let client_id_input = msg["client_id"] as! String
            if topic_id_input == topicId && client_id_input == clientID{
                self.get_last_read_id(topic_id_input: topicId!, client_id_input: clientID!)
            }
        }
    
    }
    func new_client_topic_msg(sender: String) {
        print("new_client_topic_msg")
        if sender == clientID{
            update_database()
            if topicId != nil && clientID != nil{
                let last_id = sql_database.get_topic_content_last_id_server(topic_id_input: topicId!, client_id_input: clientID!)
                print("new_client_topic_msg2")
                let sendData = [
                    "msg_type":"topic_content_read",
                    "topic_content_id":last_id
                ]
                socket.write(data:json_dumps(sendData as NSDictionary))
            }
            
        }
    }
    func new_my_topic_msg(sender: String, id_local: String) {
        DispatchQueue.main.async {
            if sender == userData.id{
                print("===new_my_topic_msg===")
                self.sending_dic.removeValue(forKey: id_local)
                self.update_database()
            }
        }
    }
    func wsReconnected(){
    }
    
    // internal func
    func send_all_msg(){
        let unsend_list = sql_database.get_unsend_topic_data(topic_id_input: topicId!, client_id: ownerId!)
        for unsend_list_s in unsend_list!{
            if sending_dic[unsend_list_s["id_local"] as! String] == nil{
                sending_dic[unsend_list_s["id_local"] as! String] = Int(Date().timeIntervalSince1970)
                socket.write(data: json_dumps(unsend_list_s))
            }
        }
        reset_sending_dic_after_5_sec()
        reload_after_5_sec()
        update_database()
        self.scroll(to: IndexPath(row: messages.count, section: 0), animated: true)
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
        self.scroll(to: IndexPath(row: messages.count, section: 0), animated: false)
    }
    func get_history_new(){
        let last_id_server:String = sql_database.get_topic_content_last_id_server(topic_id_input: topicId!, client_id_input: clientID!)
        var init_sql_state = "0"
        if init_sql{
            init_sql_state = "1"
            init_sql = false
        }
        let request_dic:Dictionary<String,String> = [
            "last_id_server":last_id_server,
            "client_id":clientID!,
            "topic_id":topicId!,
            "init_sql":init_sql_state
        ]
        HttpRequestCenter().request_user_data("history_topic_msg_new", send_dic: request_dic) { (return_dic) in
            if return_dic["result"] as! String == "not_exist"{
                //close topic
            }
            else if return_dic["result"] as! String == "no_new_data"{
                DispatchQueue.main.async {
                    self.update_database()
                    self.enter_topic_signal()
                }
            }
            else if return_dic["result"] as! String == "success"{
                let data_list:Array<Dictionary<String,AnyObject>> = return_dic["data_list"]! as! Array<Dictionary<String, AnyObject>>
                
                for data in data_list{
                    sql_database.inser_date_to_topic_content(input_dic: data)
                    //sql_database.print_all()
                }
                DispatchQueue.main.async {
                    self.update_database()
                    self.enter_topic_signal()
                }
            }
            
        }
    }
    func get_last_read_id(topic_id_input:String, client_id_input:String){
        var init_sql_state = "0"
        if init_sql{
            init_sql_state = "1"
            init_sql = false
        }
        let send_dic:Dictionary<String,String> = [
            "topic_id":topic_id_input,
            "client_id":client_id_input,
            "init_sql":init_sql_state
        ]
        HttpRequestCenter().request_user_data("get_last_read_id", send_dic: send_dic) { (return_dic) in
            let last_local_id = return_dic["last_read_id"]! as! String
            print(last_local_id)
            if last_local_id != "0"{
                sql_database.update_topic_content_read(id_local: last_local_id)
                DispatchQueue.main.async {
                    self.update_database()
                }
            }
            
        }
        
    }
    func enter_topic_signal(){
        if topicId != nil && clientID != nil{
            let sen_dic:NSDictionary = [
                "msg_type":"enter_topic",
                "topic_id":topicId!,
                "client_id":clientID!
            ]
            socket.write(data: json_dumps(sen_dic))
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
    func reload_after_5_sec(){
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update_database), userInfo: nil, repeats: false)
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
        print(sending_dic)
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
}



class JSQMessage2:JSQMessage{
    var topicContentId:String?  //來自server定義的id
    var topicTempid:String? //臨時自定義id
    var isRead:Bool?
    var show_resend_btn = false
    var is_resending = false
}



//未送訊息解法，在每一訊息上綁定click功能，在Ｊmsg屬性裡自訂未讀狀態：Ｂool
//並利用uincode寫入驚嘆號及“未送出”字樣




