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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //guestPhoto.image = ownerImg
        wsActive.wasd_ForTopicViewController = self
        topicTitleContent.text = topicTitle
        setImage()
        getHttpData()
    }
    
    
    
    @IBAction func addFriendClick(_ sender: AnyObject) {
        btnAddFriend.layer.backgroundColor = UIColor(red:0.98, green:0.40, blue:0.20, alpha:0.9).cgColor
        btnAddFriend.layer.borderWidth = 0
    }
    @IBAction func addFriendRelease(_ sender: AnyObject) {
        btnAddFriend.layer.backgroundColor = UIColor.white.cgColor
        btnAddFriend.layer.borderWidth = 1
    }
    @IBAction func btnIgnorClick(_ sender: AnyObject) {
        btnIgnroe.layer.backgroundColor = UIColor(red:0.98, green:0.40, blue:0.20, alpha:0.9).cgColor
        btnIgnroe.layer.borderWidth = 0
    }
    @IBAction func btnIgnorRelease(_ sender: AnyObject) {
        btnIgnroe.layer.backgroundColor = UIColor.white.cgColor
        btnIgnroe.layer.borderWidth = 1
    }
    @IBAction func btnBlockClick(_ sender: AnyObject) {
        btnBlock.layer.backgroundColor = UIColor(red:0.98, green:0.40, blue:0.20, alpha:0.9).cgColor
        btnBlock.layer.borderWidth = 0
    }
    @IBAction func btnBlockRelease(_ sender: AnyObject) {
        btnBlock.layer.backgroundColor = UIColor.white.cgColor
        btnBlock.layer.borderWidth = 1
    }
    
    
    
    
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
                        self.myPhoto.image = myImg
                        
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
                            myPhoto.image = tempImg
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
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatViewCon = segue.destination as! ChatViewController
        chatViewCon.setID = userData.id
        chatViewCon.setName = userData.name
        chatViewCon.topicId = self.topicId
        chatViewCon.ownerId = self.ownerId
        if self.msg == nil {
            self.contanterView = chatViewCon
        }
        else{
            chatViewCon.historyMsg = self.msg!
        }
    }
    
    
    // 設置照片+按鈕外觀
    func setImage(){
        guestPhoto.image = ownerImg
        
        // MARK: 照片圓角
        myPhoto.layoutIfNeeded()
        myPhoto.layer.cornerRadius = myPhoto.frame.size.width/2
        myPhoto.clipsToBounds = true
        
        guestPhoto.layoutIfNeeded()
        guestPhoto.layer.cornerRadius = guestPhoto.frame.size.width/2
        guestPhoto.clipsToBounds = true
        
        // MARK: 照片陰影 (先作陰影在蓋上照片)
        let myPhotoShadow = UIView(frame: myPhoto.frame)
        myPhoto.frame = CGRect(x: 0, y: 0, width: myPhoto.frame.size.width, height: myPhoto.frame.size.height)
        myPhotoShadow.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).cgColor
        myPhotoShadow.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        myPhotoShadow.layer.shadowOpacity = 1
        myPhotoShadow.layer.shadowRadius = 1
        myPhotoShadow.layer.cornerRadius = myPhoto.frame.size.width/2
        myPhotoShadow.clipsToBounds = false
        myPhotoShadow.addSubview(myPhoto)
        self.view.addSubview(myPhotoShadow)
        
        let guestPhotoShadow = UIView(frame: guestPhoto.frame)
        guestPhoto.frame = CGRect(x: 0, y: 0, width: guestPhoto.frame.size.width, height: guestPhoto.frame.size.height)
        myPhotoShadow.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).cgColor
        myPhotoShadow.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        myPhotoShadow.layer.shadowOpacity = 1
        myPhotoShadow.layer.shadowRadius = 1
        myPhotoShadow.layer.cornerRadius = guestPhoto.frame.size.width/2
        myPhotoShadow.clipsToBounds = false
        myPhotoShadow.addSubview(guestPhoto)
        self.view.addSubview(guestPhotoShadow)
        
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
}
