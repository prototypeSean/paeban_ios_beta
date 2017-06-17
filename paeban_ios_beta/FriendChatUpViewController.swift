//
//  FriendChatUpViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/5.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class FriendChatUpViewController: UIViewController {
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var reportOutlet: UIButton!
    @IBOutlet weak var blockOutlet: UIButton!
    @IBOutlet weak var myPhoto: UIImageView!
    @IBOutlet weak var guestPhoto: UIImageView!
    
    @IBOutlet weak var topicInfoBG: UIView!
    
    @IBOutlet weak var topicTitleContent: UILabel!
    @IBAction func report(_ sender: AnyObject) {
        reportAbuse()
    }
    @IBAction func block(_ sender: AnyObject) {
        block()
    }
    
    
    var setID:String?
    var setName:String?
    var setImg:UIImage?
    var clientImg:UIImage?
    var clientId:String?
    var clientName:String?
    var contanterView:FriendChatViewController?
    var msg:Dictionary<String,AnyObject>?
    var chat_view:FriendChatViewController?
    var guestPhotoImg = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topicTitleContent.text = clientName
    }
    
    override func viewDidLayoutSubviews() {
        setImage()
        setButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatViewCon = segue.destination as! FriendChatViewController
        chatViewCon.setID = userData.id
        chatViewCon.setName = userData.name
        chatViewCon.clientId = self.clientId
        chatViewCon.clientName = self.clientName
        chat_view = chatViewCon
//        if self.msg == nil {
//            self.contanterView = chatViewCon
//        }
//        else{
//            chatViewCon.historyMsg = self.msg!
//        }
    }
    func getPriMsgHistoryData(){}
    
    
    // 設置照片外觀眉角
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
        let myPhotoImg = UIImageView()
        myPhotoImg.image = setImg
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
        
    }
    

    // 封鎖
    func block(){
        let confirm = UIAlertController(title: "封鎖", message: "封鎖  \(clientName!) ? 將再也無法聯繫他", preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            let nav = self.parent as! UINavigationController
            nav.popViewController(animated: true)
            Block_list_center().add_user_to_block_list(client_id: self.clientId!)
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
            "report_id":clientId!,
        ]
        let confirm = UIAlertController(title: "舉報", message: "向管理員反應收到  \(clientName!) 的騷擾內容", preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        confirm.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: { (UIAlertAction_void) in
            HttpRequestCenter().privacy_function(msg_type: "report_friend", send_dic: sendDic, inViewAct: { (Dictionary) in
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
    
    // 按鈕初始外觀
    func setButton(){
        reportOutlet.layoutIfNeeded()
        let btn_radius:CGFloat = CGFloat(reportOutlet.bounds.size.height)/2
        reportOutlet.layer.cornerRadius = btn_radius
        reportOutlet.layer.borderWidth = 1
        reportOutlet.layer.borderColor = UIColor.gray.cgColor
        reportOutlet.clipsToBounds = true
        
        blockOutlet.layoutIfNeeded()
        blockOutlet.layer.borderWidth = 1
        blockOutlet.layer.borderColor = UIColor.gray.cgColor
        blockOutlet.layer.cornerRadius = btn_radius
        blockOutlet.clipsToBounds = true
        }
    
    func relace_chat_view_client_id(){
        chat_view?.setID = nil
        chat_view?.clientId = nil
    }
}
