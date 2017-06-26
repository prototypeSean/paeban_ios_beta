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
    func topic_has_been_closed(_ topicID:String)
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
    var myPhotoSave:UIImage?
    let myPhotoImg = UIImageView()
    var guestPhotoImg = UIImageView()
    var get_client_img_timer:Timer?
    var tags:String?
    var my_img_level:Int?
    var client_data_obj:Client_detail_data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getHttpData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wsActive.wasd_ForTopicViewController = self
        topicTitleContent.text = topicTitle
        check_is_friend()
        client_data_obj = Client_detail_data(topic_id: topicId!, client_id: ownerId!)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HttpRequestCenter().check_topic_alive(topic_id: topicId!) { (result:Bool, topic_id_ins:String) in
            DispatchQueue.main.async {
                if !result{
                    self.alertTopicClosed(topic_id_ins: topic_id_ins)
                }
            }
        }
//        setImage()
        re_new_client_img()
        my_img_level = sql_database.get_level_my(topic_id_in: topicId!, client_id: ownerId!)
        re_new_my_img()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    

    func get_client_img(owner:String,topic_id:String){
        // old
//        let httpSendDic = ["client_id":owner,
//                           "topic_id":topic_id]
//        HttpRequestCenter().getBlurImg(httpSendDic, InViewAct: { (returnData) in
//            DispatchQueue.main.async {
//                let gttp_return_img = base64ToImage(returnData["data"] as! String)
//                self.ownerImg = gttp_return_img
//                self.guestPhotoImg.image = gttp_return_img
//            }
//        })
//        get_client_img_timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.check_client_img), userInfo: nil, repeats: false)
    }
    func check_client_img(){
        if self.guestPhotoImg.image == nil{
            get_client_img(owner: ownerId!, topic_id: topicId!)
        }
    }
    
    func alertTopicClosed(topic_id_ins:String){
        let refreshAlert = UIAlertController(title: "提示".localized(withComment: "TopicViewController"), message: "話題已關閉".localized(withComment: "TopicViewController"), preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let nav_vc = self.parent as! UINavigationController
            nav_vc.popToRootViewController(animated: true)
        }))
        
        self.delegate?.topic_has_been_closed(topic_id_ins)
        sql_database.delete_topic_content(topic_id_ins:topic_id_ins)
        print("-----------------")
        print(topic_id_ins)
        print(topicId)
        if topic_id_ins == topicId{
            self.present(refreshAlert, animated: true, completion: nil)
        }
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
//        print("guestPhoto.bounds.height==",guestPhoto.bounds.height)
        // add the border to subview 第二層做邊框（這邊設0因為不需要）
        let guetsborderView = UIView()
        guetsborderView.frame = guestPhoto.bounds
//        print("guetsborderView.frame.height==",guetsborderView.frame.height)
//        print("guestPhoto.bounds.height==",guestPhoto.bounds.height)
        guetsborderView.layer.cornerRadius = guestPhoto.frame.size.height/2
        guetsborderView.layer.borderColor = UIColor.black.cgColor
        guetsborderView.layer.borderWidth = 0
        guetsborderView.layer.masksToBounds = true
        guestPhoto.addSubview(guetsborderView)
        
        // add any other subcontent that you want clipped 最上層才放圖片進去
        //let guestPhotoImg = UIImageView()
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
        
        //myPhotoImg.image = myPhotoSave
        //myPhotoImg.image = userData.img
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
        let confirm = UIAlertController(title: "封鎖".localized(withComment: "TopicViewController"), message: String(format: NSLocalizedString("封鎖%@ ? 將再也無法聯繫他", comment: "TopicViewController"), setName!), preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消".localized(withComment: "TopicViewController"), style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定".localized(withComment: "TopicViewController"), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            let nav = self.parent as! UINavigationController
            nav.popViewController(animated: true)
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
        let confirm = UIAlertController(title: "舉報".localized(withComment: "TopicViewController"), message: String(format: NSLocalizedString("向管理員反應收到%@ 的騷擾內容", comment: "TopicViewController"), setName!), preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消".localized(withComment: "TopicViewController"), style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定".localized(withComment: "TopicViewController"), style: UIAlertActionStyle.default, handler: { (UIAlertAction_void) in
            HttpRequestCenter().privacy_function(msg_type: "report_topic", send_dic: sendDic, inViewAct: { (Dictionary) in
                let msg_type = Dictionary["msg_type"] as! String
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "確定".localized(withComment: "TopicViewController"), style: UIAlertActionStyle.default, handler: nil))
                if msg_type == "success"{
                    alert.title = "舉報".localized(withComment: "TopicViewController")
                    alert.message = "感謝您的回報，我們將儘速處理".localized(withComment: "TopicViewController")
                    
                }
                else if msg_type == "user_not_exist"{
                    alert.title = "錯誤".localized(withComment: "TopicViewController")
                    alert.message = "用戶不存在".localized(withComment: "TopicViewController")
                }
                else if msg_type == "topic_not_exist"{
                    alert.title = "錯誤".localized(withComment: "TopicViewController")
                    alert.message = "話題不存在".localized(withComment: "TopicViewController")
                }
                else if msg_type == "unknown_error"{
                    alert.title = "錯誤".localized(withComment: "TopicViewController")
                    alert.message = "未知的錯誤".localized(withComment: "TopicViewController")
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
        
        let alert = UIAlertController(title: "好友邀請".localized(withComment: "TopicViewController"), message: "已送出好友邀請".localized(withComment: "TopicViewController"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確認".localized(withComment: "TopicViewController"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: delegate -> websocket
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        let msgType =  msg["msg_type"] as! String
        if msgType == "topic_closed"{
            let closeTopicId = msg["topic_id"] as? String
            if closeTopicId != nil{
                self.alertTopicClosed(topic_id_ins: closeTopicId!)
            }
        }
        else if msgType == "has_been_friend"{
            let alert = UIAlertController(title: "好友".localized(withComment: "TopicViewController"), message: "已經是好友了".localized(withComment: "TopicViewController"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定".localized(withComment: "TopicViewController"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if msgType == "has_been_block"{}
        else if msgType == "leave_topic_master_client"{
            let nav = self.parent! as! UINavigationController
            let nav_name = getClassName(classFullName:String(describing: nav))
            let owner_name = msg["owner_name"] as! String
            let topic_id = msg["topic_id"] as! String
            if topicId == topic_id{
                if nav_name == "TopicNavViewController"{
                    let alert = UIAlertController(title: "通知".localized(withComment: "TopicViewController"), message: String(format: NSLocalizedString("用戶%@ 已將您移出話題%@", comment: "TopicViewController"), owner_name, topicTitle!), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "確認".localized(withComment: "TopicViewController"), style: .default, handler: { (act) in
                        nav.popToRootViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    nav.popToRootViewController(animated: true)
                }
            }
        }
    }
    func wsReconnected(){
    }
    func new_my_topic_msg(sender: String, id_local: String) {
        check_my_photo_level()
    }
    func new_client_topic_msg(sender: String) {
        re_new_client_img()
    }
    func re_new_client_img(){
        client_data_obj!.get_client_img(act: { (return_img:UIImage?) in
            if return_img != nil{
                self.ownerImg = return_img
                self.guestPhotoImg.image = return_img
            }
        })
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
        chatViewCon.tags = self.tags
        chatViewCon.topic_title_var = self.topicTitle
        if self.msg == nil {
            self.contanterView = chatViewCon
        }
        
    }
    private func getViewController(indentifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(indentifier)")
    }
    private func check_is_friend(){
        //working
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
    
    // test
    func check_my_photo_level(){
        let new_level = sql_database.get_level_my(topic_id_in: self.topicId!, client_id: self.ownerId!)
        if self.my_img_level != new_level{
            self.my_img_level = new_level
            re_new_my_img()
        }
    }
    func re_new_my_img(){
        DispatchQueue.global(qos: .background).async {
            let level = sql_database.get_level_my(topic_id_in: self.topicId!, client_id: self.ownerId!)
            print("=====level_my:\(level)")
            if userData.img != nil{
                let temp_img = self.set_my_img_level(input_img: userData.img!, level_input: level)
                DispatchQueue.main.async {
                    self.myPhotoImg.image = temp_img
                }
            }
        }
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
    
}
