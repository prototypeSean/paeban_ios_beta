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
    
    @IBOutlet weak var myPhoto: UIImageView!
    @IBOutlet weak var guestPhoto: UIImageView!
    
    @IBOutlet weak var topicInfoBG: UIView!
    
    @IBOutlet weak var topicTitleContent: UILabel!
    
    //var delegate:TopicViewControllerDelegate?
    var setID:String?
    var setName:String?
    var setImg:UIImage?
    var clientImg:UIImage?
    var clientId:String?
    var clientName:String?
    var contanterView:FriendChatViewController?
    var msg:Dictionary<String,AnyObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        topicTitleContent.text = clientName
        myPhoto.image = setImg
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatViewCon = segue.destination as! FriendChatViewController
        chatViewCon.setID = userData.id
        chatViewCon.setName = userData.name
        chatViewCon.clientId = self.clientId
        chatViewCon.clientName = self.clientName
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
        guestPhoto.image = clientImg
        
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
        
    }

    

}
