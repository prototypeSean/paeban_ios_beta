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
    let gradientLayer = CAGradientLayer()
    
    var setID:String?
    var setName:String?
    var topicId:String?
    var clientImg:UIImage?
    var topicTitle:String?
    var ownerId:String?
    var contanterView:ChatViewController?
    var msg:Dictionary<String,AnyObject>?
    
    // internal func
    func setImage(){
        guestPhoto.image = clientImg
        
        // MARK: 試著把照片切成圓形
        let myPhotoLayer:CALayer = myPhoto.layer
        myPhotoLayer.masksToBounds = true
        myPhotoLayer.cornerRadius = myPhoto.frame.size.width/2
        
        guestPhoto.layer.cornerRadius = guestPhoto.frame.size.width/2
        guestPhoto.clipsToBounds = true
        
        // MARK: 照片陰影
        let myPhotoShadow = UIView(frame: myPhoto.frame)
        myPhoto.frame = CGRect(x: 0, y: 0, width: myPhoto.frame.size.width, height: myPhoto.frame.size.height)
        myPhotoShadow.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).cgColor
        myPhotoShadow.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        myPhotoShadow.layer.shadowOpacity = 1
        myPhotoShadow.layer.shadowRadius = 1
        myPhotoShadow.layer.cornerRadius = myPhoto.frame.size.width/2
        myPhotoShadow.clipsToBounds = false
        myPhotoShadow.addSubview(myPhoto)
        
        let guestPhotoShadow = UIView(frame: guestPhoto.frame)
        guestPhoto.frame = CGRect(x: 0, y: 0, width: guestPhoto.frame.size.width, height: guestPhoto.frame.size.height)
        myPhotoShadow.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).cgColor
        myPhotoShadow.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        myPhotoShadow.layer.shadowOpacity = 1
        myPhotoShadow.layer.shadowRadius = 1
        myPhotoShadow.layer.cornerRadius = guestPhoto.frame.size.width/2
        myPhotoShadow.clipsToBounds = false
        myPhotoShadow.addSubview(guestPhoto)
        
        self.view.addSubview(myPhotoShadow)
        self.view.addSubview(guestPhotoShadow)
        
        // MARK: 作邊框
        topicInfoBG.layer.borderWidth = 1
        topicInfoBG.layer.borderColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:0.3).cgColor
        
        // MARK: 漸層
        topicInfoBG.backgroundColor = UIColor.white
        gradientLayer.frame = topicInfoBG.bounds
        let color1 = UIColor(red:0.97, green:0.97, blue:0.97, alpha:0.2).cgColor as CGColor
        let color2 = UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.2).cgColor as CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        
        topicInfoBG.layer.addSublayer(gradientLayer)
    }
    func getHistory(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { 
            let http_obj = HttpRequestCenter()
            http_obj.getTopicContentHistory(self.setID!, topicId: self.topicId!, InViewAct: { (returnDic) in
                
                let checkMsgType = returnDic.index(where: { (msg_type, _) -> Bool in
                    if msg_type == "msg_type"{
                        //話題已關閉
                        return true
                    }
                    else{
                        return false
                    }
                })
                
                if checkMsgType == nil{
                    let myImg = base64ToImage(returnDic["my_img"] as! String)
                    
                    let msg = returnDic["msg"] as! Dictionary<String,AnyObject>
                    DispatchQueue.main.async(execute: {
                        self.myPhoto.image = myImg
                        
                        let chatViewCon = self.contanterView
                        chatViewCon?.historyMsg = msg
                        self.msg = msg
                    })
                }
                else{
                    DispatchQueue.main.async(execute: {
                        //self.alertTopicClosed()
                    })
                }
            })
        }
    }
    func alertTopicClosed(){
        let refreshAlert = UIAlertController(title: "提示", message: "話題已關閉", preferredStyle: UIAlertControllerStyle.alert)
        
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
    
    // override
    override func viewDidLoad() {
        super.viewDidLoad()
        wsActive.wasd_ForMyTopicViewController = self
        guestPhoto.image = clientImg //修正後移除
        topicTitleContent.text = topicTitle
        getHistory()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatViewCon = segue.destination as! ChatViewController
        chatViewCon.setID = userData.id
        chatViewCon.setName = userData.name
        chatViewCon.topicId = self.topicId
        chatViewCon.ownerId = self.setID
        chatViewCon.clientID = self.setID
        chatViewCon.clientName = self.setName
        
        
        if self.msg == nil {
            self.contanterView = chatViewCon
        }
        else{
            chatViewCon.historyMsg = self.msg!
        }
    }
    
    
    // delegate -> websocket
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
    
}











