//
//  MyTopicViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/8/28.
//  Copyright © 2016年 尚義 高. All rights reserved.
//


import UIKit

import JSQMessagesViewController

class MyTopicViewController: UIViewController ,webSocketActiveCenterDelegate{

    @IBOutlet weak var guestPhoto: UIImageView!
    @IBOutlet weak var myPhoto: UIImageView!
    @IBOutlet weak var topicTitleContent: UILabel!
    @IBOutlet weak var topicInfoBG: UIView!
    @IBOutlet weak var btnAddFriend: UIButton!
    @IBOutlet weak var btnIgnroe: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
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
    @IBOutlet weak var popUpImg: UIImageView!
    @IBOutlet weak var popUpViewCenterY: NSLayoutConstraint!
    @IBAction func popUpImgBtn(_ sender: Any) {
        popUpViewCenterY.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutSubviews()
        })
        popUpImg.image = guestPhotoImg.image
    }
    
    @IBAction func popUpCloseBtn(_ sender: Any) {
        popUpViewCenterY.constant = -1200
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutSubviews()
        })

    }
    var myPhotoSave:UIImage?
    let myPhotoImg = UIImageView()
    
    let gradientLayer = CAGradientLayer()
    
    var setID:String?
    var setName:String?
    var topicId:String?
    var clientImg:UIImage?
    var topicTitle:String?
    var ownerId:String?
    var contanterView:ChatViewController?
    var msg:Dictionary<String,AnyObject>?
    var isfriend = false
    var model:MyTopicTableViewModel?
    
    var guestPhotoImg = UIImageView()
    var client_data_obj:Client_detail_data?
    var my_img_level:Int?
    // internal func
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
        
        guestPhotoImg.image = clientImg
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
        myPhotoImg.frame = myphotoborderView.bounds
        myphotoborderView.addSubview(myPhotoImg)
    }
    func setBgImg(){
        // MARK: topicInfoBG背景白色漸層
        topicInfoBG.layer.borderColor = UIColor.gray.cgColor
        topicInfoBG.layer.borderWidth = 0.5
        
        topicInfoBG.backgroundColor = UIColor.white
//        gradientLayer.frame = topicInfoBG.bounds
//        let color1 = UIColor.clear
//        let color2 = UIColor.clear
//        gradientLayer.colors = [color1, color2]
//        gradientLayer.locations = [0.0, 1.0]
//        topicInfoBG.layer.addSublayer(gradientLayer)
        
        //      MARK: 設定按鈕
        // 設定自動調整按鈕文字大小
        btnAddFriend.titleLabel?.adjustsFontSizeToFitWidth = true
        btnAddFriend.titleLabel?.minimumScaleFactor = 0.7
        btnIgnroe.titleLabel?.adjustsFontSizeToFitWidth = true
        btnIgnroe.titleLabel?.minimumScaleFactor = 0.7
        btnBlock.titleLabel?.adjustsFontSizeToFitWidth = true
        btnBlock.titleLabel?.minimumScaleFactor = 0.7
        
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
    
    

    func alertTopicClosed(){
        let refreshAlert = UIAlertController(title: "提示".localized(withComment: "MyTopicViewController"), message: "此話題已關閉".localized(withComment: "MyTopicViewController"), preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: {
                //code
            })
        }))
        self.present(refreshAlert, animated: true, completion: nil)
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
//        let data:NSDictionary = [
//            "block_id":setID!,
//            "topic_id":topicId!
//        ]
        let confirm = UIAlertController(title: "封鎖".localized(withComment: "MyTopicViewController"), message: String(format: NSLocalizedString("封鎖 %@ ? 將再也無法聯繫他", comment: "FriendChatUpVC"),setName!) , preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消".localized(withComment: "MyTopicViewController"), style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicViewController"), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            Block_list_center().add_user_to_block_list(client_id: self.setID!)
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
        }))
        self.present(confirm, animated: true, completion: nil)
        
    }
        // 舉報
    func reportAbuse(){
        let sendDic:NSDictionary = [
            "report_id":setID!,
            "topic_id":topicId!
        ]
        let confirm = UIAlertController(title: "舉報".localized(withComment: "MyTopicViewController"), message: String(format: NSLocalizedString("向管理員反應收到%@ 的騷擾內容", comment: "MyTopicViewController"), setName!), preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消".localized(withComment: "MyTopicViewController"), style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicViewController"), style: UIAlertActionStyle.default, handler: { (UIAlertAction_void) in
            HttpRequestCenter().privacy_function(msg_type: "report_topic", send_dic: sendDic, inViewAct: { (Dictionary) in
                let msg_type = Dictionary["msg_type"] as! String
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicViewController"), style: UIAlertActionStyle.default, handler: nil))
                if msg_type == "success"{
                    alert.title = "舉報".localized(withComment: "MyTopicViewController")
                    alert.message = "感謝您的回報，我們將儘速處理".localized(withComment: "MyTopicViewController")
                    
                }
                else if msg_type == "user_not_exist"{
                    alert.title = "錯誤".localized(withComment: "MyTopicViewController")
                    alert.message = "用戶不存在".localized(withComment: "MyTopicViewController")
                }
                else if msg_type == "topic_not_exist"{
                    alert.title = "錯誤".localized(withComment: "MyTopicViewController")
                    alert.message = "話題不存在".localized(withComment: "MyTopicViewController")
                }
                else if msg_type == "unknown_error"{
                    alert.title = "錯誤".localized(withComment: "MyTopicViewController")
                    alert.message = "未知的錯誤".localized(withComment: "MyTopicViewController")
                }
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                    
                }
            })
        }))
        self.present(confirm, animated: true, completion: nil)
        
    }
    func addFriend(){
        let alert = UIAlertController(title: "好友邀請".localized(withComment: "MyTopicViewController"), message: "已送出好友邀請".localized(withComment: "MyTopicViewController"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確認".localized(withComment: "MyTopicViewController"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        let sendDic:NSDictionary = [
            "msg_type":"add_friend",
            "friend_id":setID!
        ]
        socket.write(data: json_dumps(sendDic))
    }
    
    
    
    // override
    override func viewDidLoad() {
        super.viewDidLoad()
        wsActive.wasd_ForMyTopicViewController = self
//        setImage()
        topicTitleContent.text = topicTitle
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setBgImg()
        self.check_is_friend()
        client_data_obj = Client_detail_data(topic_id: topicId!, client_id: setID!)
        self.title = ""
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setImage()
        re_new_my_img()
        re_new_client_img()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatViewCon = segue.destination as! ChatViewController
        chatViewCon.setID = userData.id
        chatViewCon.setName = userData.name
        chatViewCon.topicId = self.topicId
        chatViewCon.ownerId = self.setID
        chatViewCon.clientID = self.setID
        chatViewCon.clientName = self.setName
        chatViewCon.model = self.model
        chatViewCon.topic_title_var = self.topicTitle
        
        if self.msg == nil {
            self.contanterView = chatViewCon
        }
        else{
            //chatViewCon.historyMsg = self.msg!
        }
    }
    
    func check_my_photo_level(){
        
        let new_level = sql_database.get_level_my(topic_id_in: self.topicId!, client_id: self.ownerId!)
        if self.my_img_level != new_level{
            self.my_img_level = new_level
            re_new_my_img()
        }
    }
    func re_new_my_img(){
        DispatchQueue.global(qos: .background).async {
            let level = sql_database.get_level_my(topic_id_in: self.topicId!, client_id: self.setID!)
            print("=====level_my:\(level)")
            if userData.img != nil{
                let temp_img = self.set_my_img_level(input_img: userData.img!, level_input: level)
                DispatchQueue.main.async {
                    self.myPhotoImg.image = temp_img
                }
            }
        }
    }
    func re_new_client_img(){
        client_data_obj?.get_client_data(act: { (return_dic:Dictionary<String, AnyObject>) in
            let img_str = return_dic["img"] as! String
            let img = base64ToImage(img_str)
            self.guestPhotoImg.image = img
            self.setName = return_dic["client_name"] as? String
            self.title = self.setName
        })
    }
    func set_my_img_level(input_img:UIImage, level_input:Int)->UIImage?{
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: input_img)
        let blur_parameter = my_blur_img_level_dic[level_input]!
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(blur_parameter, forKey: kCIInputRadiusKey)
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        return processedImage
    }
    
    // delegate -> websocket
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        // 照片轉交給其他機制
        if msgType == "topic_msg"{
//            let resultDic:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary
//            if msg["img"] as? String != nil && msg["img"] as? String != ""{
//                let imgStr = msg["img"] as? String
//                let tempImg = updateImg(imgStr)
//                if tempImg != nil{
//                    //print("updateImg")
//                    for dicKey in resultDic{
//                        let msgData = dicKey.1 as! Dictionary<String,AnyObject>
//                        let sender = msgData["sender"] as! String
//                        let receiver = msgData["receiver"] as! String
//                        if sender == userData.id && receiver == setID{
//                            myPhotoImg.image = tempImg
//                            myPhotoSave = tempImg
//                        }
//                        else if receiver == userData.id && sender == setID{
//                            guestPhotoImg.image = tempImg
//                            clientImg = tempImg
//                        }
//                        break
//                    }
//                }
//            }
        }
            
        else if msgType == "topic_closed"{
            let topic_id = msg["topic_id"] as? String
            if topic_id != nil{
                self.alertTopicClosed()
            }
        }
        else if msgType == "has_been_friend"{
            let alert = UIAlertController(title: "好友".localized(withComment: "MyTopicViewController"), message: "已經是好友了".localized(withComment: "MyTopicViewController"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定".localized(withComment: "MyTopicViewController"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if msgType == "leave_topic_owner"{
            let topic_id = msg["topic_id"] as! String
            if topic_id == topicId{
                if let nav = self.parent as? UINavigationController{
                    nav.popToRootViewController(animated: true)
                }
            }
        }
        
        
    }
    func wsReconnected(){
    }
    func new_client_topic_msg(sender: String) {
        client_data_obj?.get_client_img { (return_img:UIImage?) in
            if return_img != nil{
                self.guestPhotoImg.image = return_img
            }
        }
    }
    func new_my_topic_msg(sender: String, id_local: String) {
        check_my_photo_level()
    }
    func reset_during_auto_leap(){
        during_auto_leap = false
    }
    private func check_is_friend(){
        if let _ = myFriendsList.index(where: { (element) -> Bool in
            if element.id == setID{
                return true
            }
            return false
        }){
            btnAddFriend.backgroundColor = UIColor.gray
            btnAddFriend.setTitleColor(.white, for: .normal)
            isfriend = true
        }
        else{
            btnAddFriend.backgroundColor = nil
            isfriend = false
        }
    }
    
}











