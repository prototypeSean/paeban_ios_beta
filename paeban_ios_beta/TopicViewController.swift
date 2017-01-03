//
//  TopicViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/27.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
import JSQMessagesViewController
protocol TopicViewControllerDelegate {
    func reLoadTopic(_ topicID:String)
}

class TopicViewController: UIViewController,webSocketActiveCenterDelegate {
    // 替漸層增加一個圖層
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var myPhoto: UIImageView!
    @IBOutlet weak var guestPhoto: UIImageView!
    
    @IBOutlet weak var topicInfoBG: UIView!
    
    @IBOutlet weak var topicTitleContent: UILabel!
    
    @IBOutlet weak var btnAddFriend: UIButton!
    @IBOutlet weak var btnIgnroe: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
    
    var delegate:TopicViewControllerDelegate?
    var setID:String?
    var setName:String?
    var topicId:String?
    var ownerImg:UIImage?
    var topicTitle:String?
    var ownerId:String?
    var contanterView:ChatViewController?
    var msg:Dictionary<String,AnyObject>?
    var isfriend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wsActive.wasd_ForTopicViewController = self
        getHttpData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topicTitleContent.text = topicTitle
        check_is_friend()
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.dismiss(animated: false, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        setImage()
    }
    
        
    
    @IBAction func addFriendClick(_ sender: AnyObject) {
        if !isfriend{
            btnAddFriend.layer.backgroundColor = UIColor(red:0.98, green:0.40, blue:0.20, alpha:0.9).cgColor
            btnAddFriend.layer.borderWidth = 0
        }
    }
    @IBAction func addFriendRelease(_ sender: AnyObject) {
        if !isfriend{
            btnAddFriend.layer.backgroundColor = UIColor.white.cgColor
            btnAddFriend.layer.borderWidth = 1
            addFriend()
        }
    }
    @IBAction func btnIgnorClick(_ sender: AnyObject) {
        btnIgnroe.layer.backgroundColor = UIColor(red:0.98, green:0.40, blue:0.20, alpha:0.9).cgColor
        btnIgnroe.layer.borderWidth = 0
    }
    @IBAction func btnIgnorRelease(_ sender: AnyObject) {
        btnIgnroe.layer.backgroundColor = UIColor.white.cgColor
        btnIgnroe.layer.borderWidth = 1
        reportAbuse()
    }
    @IBAction func btnBlockClick(_ sender: AnyObject) {
        btnBlock.layer.backgroundColor = UIColor(red:0.98, green:0.40, blue:0.20, alpha:0.9).cgColor
        btnBlock.layer.borderWidth = 0
    }
    @IBAction func btnBlockRelease(_ sender: AnyObject) {
        btnBlock.layer.backgroundColor = UIColor.white.cgColor
        btnBlock.layer.borderWidth = 1
        block()
    }
    
    var myPhotoSave:UIImage?
    let myPhotoImg = UIImageView()
    // MARK: internal func
    func getHttpData() {
        DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async{ () -> Void in
            let httpObj = HttpRequestCenter()
            httpObj.getTopicContentHistory(self.ownerId!,topicId: self.topicId!, InViewAct: { (returnData2) in
//                returnData2:
//                unblock_level
//                img
//                my_img
//                msg
                
                let checkMsgType = returnData2.index(where: { (msg_type, _) -> Bool in
                    if msg_type == "msg_type"{
                        //話題已關閉
                        return true
                    }
                    else{
                        return false
                    }
                })
                
                if checkMsgType == nil{
                    let myImg = base64ToImage(returnData2["my_img"] as! String)
                    
                    let msg = returnData2["msg"] as! Dictionary<String,AnyObject>
                    DispatchQueue.main.async(execute: {
                        self.myPhotoSave = myImg
                        self.myPhotoImg.image = self.myPhotoSave
                        let chatViewCon = self.contanterView
                        chatViewCon?.historyMsg = msg
                        self.msg = msg
                    })
                }
                else{
                    DispatchQueue.main.async(execute: {
                        self.alertTopicClosed()
                    })
                }
            })
        }
    }
    func alertTopicClosed(){
        let refreshAlert = UIAlertController(title: "提示", message: "話題已關閉", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //self.navigationController?.popViewController(animated: true)
        }))
        
        self.delegate?.reLoadTopic(self.topicId!)
        self.present(refreshAlert, animated: true, completion: nil)
    }
        // 設置照片+按鈕外觀
    func setImage(){
        // MARK: 為了陰影跟圓角 要作三層圖曾
        // add the shadow to the base view 最底層作陰影
        guestPhoto.backgroundColor = UIColor.clear
        guestPhoto.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).cgColor
        guestPhoto.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        guestPhoto.layer.shadowOpacity = 1
        guestPhoto.layer.shadowRadius = 2
        
        // add the border to subview 第二層做邊框（這邊設0因為不需要）
        let guetsborderView = UIView()
        guetsborderView.frame = guestPhoto.bounds
        guetsborderView.layer.cornerRadius = guestPhoto.frame.size.height/2
        guetsborderView.layer.borderColor = UIColor.black.cgColor
        guetsborderView.layer.borderWidth = 0
        guetsborderView.layer.masksToBounds = true
        guestPhoto.addSubview(guetsborderView)
        
        // add any other subcontent that you want clipped 最上層才放圖片進去
        let guestPhotoImg = UIImageView()
        guestPhotoImg.image = ownerImg
        guestPhotoImg.frame = guetsborderView.bounds
        guetsborderView.addSubview(guestPhotoImg)
        
        // -------------------上面guest 下面自己------------------------
        
        // add the shadow to the base view 最底層作陰影
        myPhoto.backgroundColor = UIColor.clear
        myPhoto.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).cgColor
        myPhoto.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        myPhoto.layer.shadowOpacity = 1
        myPhoto.layer.shadowRadius = 2
        
        // add the border to subview 第二層做邊框（這邊設0因為不需要）
        let myphotoborderView = UIView()
        myphotoborderView.frame = myPhoto.bounds
        myphotoborderView.layer.cornerRadius = guestPhoto.frame.size.height/2
        myphotoborderView.layer.borderColor = UIColor.black.cgColor
        myphotoborderView.layer.borderWidth = 0
        myphotoborderView.layer.masksToBounds = true
        myPhoto.addSubview(myphotoborderView)
        
        // add any other subcontent that you want clipped 最上層才放圖片進去
        
        myPhotoImg.image = myPhotoSave
        //        print(myPhotoSave)
        myPhotoImg.frame = myphotoborderView.bounds
        myphotoborderView.addSubview(myPhotoImg)
        
        // MARK: topicInfoBG背景白色漸層
        topicInfoBG.layer.borderColor = UIColor.gray.cgColor
        topicInfoBG.layer.borderWidth = 0.5
        
        topicInfoBG.backgroundColor = UIColor.white
        gradientLayer.frame = topicInfoBG.bounds
        let color1 = UIColor(red:0.97, green:0.97, blue:0.97, alpha:0.2).cgColor as CGColor
        let color2 = UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.2).cgColor as CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        topicInfoBG.layer.addSublayer(gradientLayer)
        
        //MARK: 設定按鈕
        // 按下按鈕文字回白
        btnAddFriend.setTitleColor(UIColor.white, for: .highlighted)
        btnIgnroe.setTitleColor(UIColor.white, for: .highlighted)
        btnBlock.setTitleColor(UIColor.white, for: .highlighted)
        
        // 按鈕初始外觀
        btnAddFriend.layoutIfNeeded()
        let btn_radius:CGFloat = CGFloat(btnAddFriend.bounds.size.height)/2
        btnAddFriend.layer.cornerRadius = btn_radius
        btnAddFriend.layer.borderWidth = 1
        btnAddFriend.layer.borderColor = UIColor.gray.cgColor
        btnAddFriend.clipsToBounds = true
        
        btnIgnroe.layoutIfNeeded()
        btnIgnroe.layer.borderWidth = 1
        btnIgnroe.layer.borderColor = UIColor.gray.cgColor
        btnIgnroe.layer.cornerRadius = btn_radius
        btnIgnroe.clipsToBounds = true
        
        btnBlock.layoutIfNeeded()
        btnBlock.layer.borderWidth = 1
        btnBlock.layer.borderColor = UIColor.gray.cgColor
        btnBlock.layer.cornerRadius = btn_radius
        btnBlock.clipsToBounds = true
        
    }
    fileprivate func updateImg(_ imgString:String?) -> UIImage?{
        if imgString != nil{
            let img = base64ToImage(imgString!)
            return img
        }
        else{return nil}
    }
        // 封鎖
    func block(){
        let data:NSDictionary = [
            "block_id":setID!,
            "topic_id":topicId!
        ]
        let confirm = UIAlertController(title: "封鎖", message: "封鎖  \(setName!) ? 將再也無法聯繫他", preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            let nav = self.parent as! UINavigationController
            nav.popViewController(animated: true)
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
            
            
            
        }))
        self.present(confirm, animated: true, completion: nil)
        
    }
        // 舉報
    func reportAbuse(){
        let sendDic:NSDictionary = [
            "report_id":setID!,
            "topic_id":topicId!
        ]
        let confirm = UIAlertController(title: "舉報", message: "向管理員反應收到  \(setName!) 的騷擾內容", preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: { (UIAlertAction_void) in
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
        }))
        self.present(confirm, animated: true, completion: nil)
        
    }
    func addFriend(){
        let sendDic:NSDictionary = [
            "msg_type":"add_friend",
            "friend_id":setID!
        ]
        socket.write(data: json_dumps(sendDic))
        
        let alert = UIAlertController(title: "好友邀請", message: "已送出好友邀請", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: delegate -> websocket
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        if msgType == "topic_msg"{
            let resultDic:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary
            if msg["img"] as? String != nil && msg["img"] as? String != ""{
                let imgStr = msg["img"] as? String
                let tempImg = updateImg(imgStr)
                if tempImg != nil{
                    //print("updateImg")
                    for dicKey in resultDic{
                        let msgData = dicKey.1 as! Dictionary<String,AnyObject>
                        let sender = msgData["sender"] as! String
                        if sender == userData.id{
                            myPhotoSave = tempImg
                            myPhotoImg.image = myPhotoSave
//                            print("refresh")
                        }
                        else{
                            guestPhoto.image = tempImg
                        }
                        break
                    }
                }
            }
        }
        else if msgType == "topic_closed"{
            let closeTopicIdList:Array<String>? = msg["topic_id"] as? Array
            if closeTopicIdList != nil{
                if closeTopicIdList?.index(of: self.topicId!) != nil{
                    self.alertTopicClosed()
                }
            }
        }
        else if msgType == "has_been_friend"{
            let alert = UIAlertController(title: "好友", message: "已經是好友了", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if msgType == "has_been_block"{}
        
        
    }
    
    // MARK: override function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatViewCon = segue.destination as! ChatViewController
        chatViewCon.setID = userData.id
        chatViewCon.setName = userData.name
        chatViewCon.topicId = self.topicId
        chatViewCon.ownerId = self.ownerId
        chatViewCon.clientID = self.setID
        chatViewCon.clientName = self.setName
        
        if self.msg == nil {
            self.contanterView = chatViewCon
        }
        else{
            chatViewCon.historyMsg = self.msg!
        }
    }
    private func getViewController(indentifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(indentifier)")
    }
    private func check_is_friend(){
        if let _ = myFriendsList.index(where: { (element) -> Bool in
            if element.id == ownerId{
                return true
            }
            return false
        }){
            btnAddFriend.backgroundColor = UIColor.gray
            btnAddFriend.setTitleColor(.white, for: UIControlState.normal)
            isfriend = true
        }
        else{
            btnAddFriend.backgroundColor = nil
            isfriend = false
        }
    }
    
}
