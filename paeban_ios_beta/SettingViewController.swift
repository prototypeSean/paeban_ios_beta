//
//  SettingViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/10/17.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
import Starscream

class SettingViewController: UIViewController {
    @IBOutlet weak var isTruePhotoSwitch: UISwitch!

    @IBOutlet weak var isTruePhoto: UIImageView!
    @IBAction func logOutBtn(_ sender: AnyObject) {
        logOut()
    }
    @IBOutlet weak var pencilIcon: UIImageView!
    // 本人照片開關控制勾勾圖示出現與否
    @IBAction func switchChanged(_ sender: AnyObject) {
        if isTruePhotoSwitch.isOn {
            print("on")
            
            isTruePhoto.tintColor = UIColor(red:0.00, green:0.73, blue:0.62, alpha:1.0)
        }
        else {
            print("off")
            isTruePhoto.tintColor = UIColor.clear
        }
    }
    // internal func
    func logOut(){
        cookie = nil
        myFriendsList = []
        logInState = false
        firstConnect = true
        socket.disconnect()
        fbLoginManager.logOut()
        let session = URLSession.shared
        session.finishTasksAndInvalidate()        
        session.reset {
            DispatchQueue.main.async(execute: {
                if let navc = self.parent?.parent?.parent as? UINavigationController{
                    navc.popToRootViewController(animated: true)
                }
                
            })
        }
    }
    // override
    override func viewDidLoad() {
        super.viewDidLoad()
        pencilIcon.image = UIImage(named:"pencil")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        pencilIcon.tintColor = UIColor.orange
        pencilIcon.layer.shadowColor = UIColor.black.cgColor
        pencilIcon.layer.shadowOffset = CGSize(width:2,height:2)
        // switch 原本大小是51x31 會往右下縮小
        isTruePhotoSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        // 調整勾勾圖示的預設渲染模式
        isTruePhoto.image = UIImage(named:"True_photo")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
}
