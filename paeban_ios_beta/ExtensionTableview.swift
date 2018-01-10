//
//  ExtensionTableview.swift
//  paeban_ios_beta
//
//  Created by elijah on 2018/1/10.
//  Copyright © 2018年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    func alert_unlock_distance() {
        let alert = UIAlertController(title: alert_string().notice, message: alert_string().unlock_distance, preferredStyle: .alert)
        let confirm = UIAlertAction(title: alert_string().confirm, style: .default) { (act) in
            self.unlocl_distance()
        }
        let cancel = UIAlertAction(title: alert_string().cancel, style: .default, handler: nil)
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func unlocl_distance(){
        PaidService().unlock_distance(complete: { (result_dic) in
            guard result_dic != nil else{
                let alert = UIAlertController(title: alert_string().notice, message: alert_string().internet_error_do_you_want_retry, preferredStyle: .alert)
                let confirm = UIAlertAction(title: alert_string().confirm, style: .default, handler: { (act) in
                    self.unlocl_distance()
                })
                let cancel = UIAlertAction(title: alert_string().cancel, style: .default, handler: nil)
                alert.addAction(confirm)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let RESULT = "result"
            let HAVE_BEEN_UNLOCKED = "have_been_unlocked"
            let INSUFFICIENT_COIN = "insufficient_coin"
            let UN_KNOW_ERROR_20003 = "un_know_error_20003"
            let SUCCESS = "success"
            
            let result = result_dic![RESULT] as! String
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            if result == INSUFFICIENT_COIN{
                alert.title = alert_string().warning
                alert.message = alert_string().insufficient_coin
            }
            else if result == UN_KNOW_ERROR_20003{
                alert.title = alert_string().error
                alert.message = alert_string().unknow_error_20003
            }
            else if result == SUCCESS{
                alert.title = alert_string().notice
                alert.message = alert_string().transaction_success
            }
            else if result == HAVE_BEEN_UNLOCKED{
                alert.title = alert_string().notice
                alert.message = alert_string().have_been_unlocked_distance
            }
            let confirm = UIAlertAction(title: alert_string().confirm, style: .default, handler: nil)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        })
    }
}



















