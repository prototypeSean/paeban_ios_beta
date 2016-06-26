//
//  TopicViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/27.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController {
    // 替漸層增加一個圖層
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var myPhoto: UIImageView!
    @IBOutlet weak var guestPhoto: UIImageView!
    
    @IBOutlet weak var topicInfoBG: UIView!
    
    var setID:String?
    var setName:String?
    var topicID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: 試著把照片切成圓形
        let myPhotoLayer:CALayer = myPhoto.layer
        myPhotoLayer.masksToBounds = true
        myPhotoLayer.cornerRadius = myPhoto.frame.size.width/2
        
        guestPhoto.layer.cornerRadius = guestPhoto.frame.size.width/2
        guestPhoto.clipsToBounds = true
        
        // MARK: 照片陰影
        let myPhotoShadow = UIView(frame: myPhoto.frame)
        myPhoto.frame = CGRectMake(0, 0, myPhoto.frame.size.width, myPhoto.frame.size.height)
        myPhotoShadow.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).CGColor
        myPhotoShadow.layer.shadowOffset = CGSizeMake(1.5, 1.5)
        myPhotoShadow.layer.shadowOpacity = 1
        myPhotoShadow.layer.shadowRadius = 1
        myPhotoShadow.layer.cornerRadius = myPhoto.frame.size.width/2
        myPhotoShadow.clipsToBounds = false
        myPhotoShadow.addSubview(myPhoto)
        
        let guestPhotoShadow = UIView(frame: guestPhoto.frame)
        guestPhoto.frame = CGRectMake(0, 0, guestPhoto.frame.size.width, guestPhoto.frame.size.height)
        myPhotoShadow.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).CGColor
        myPhotoShadow.layer.shadowOffset = CGSizeMake(1.5, 1.5)
        myPhotoShadow.layer.shadowOpacity = 1
        myPhotoShadow.layer.shadowRadius = 1
        myPhotoShadow.layer.cornerRadius = guestPhoto.frame.size.width/2
        myPhotoShadow.clipsToBounds = false
        myPhotoShadow.addSubview(guestPhoto)
        
        self.view.addSubview(myPhotoShadow)
        self.view.addSubview(guestPhotoShadow)
        
        // MARK: 作邊框
        topicInfoBG.layer.borderWidth = 1
        topicInfoBG.layer.borderColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:0.3).CGColor
        
        // MARK: 漸層
        topicInfoBG.backgroundColor = UIColor.whiteColor()
        gradientLayer.frame = topicInfoBG.bounds
        let color1 = UIColor(red:0.97, green:0.97, blue:0.97, alpha:0.2).CGColor as CGColorRef
        let color2 = UIColor(red:0.95, green:0.95, blue:0.95, alpha:0.2).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        
        topicInfoBG.layer.addSublayer(gradientLayer)
        
        // MARK:請求topic模式
        let httpObj = ＨttpRequsetCenter()
        httpObj.topicUserMode(self.topicID!)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let chatViewCon = segue.destinationViewController as! ChatViewController
        chatViewCon.setID = userData.id
        chatViewCon.setName = userData.name
    }

}
