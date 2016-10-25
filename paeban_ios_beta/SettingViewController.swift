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

    @IBAction func logOutBtn(_ sender: AnyObject) {
        logOut()
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

        // Do any additional setup after loading the view.
    }


}
