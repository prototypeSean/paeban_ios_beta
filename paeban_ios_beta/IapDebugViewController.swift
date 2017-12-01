//
//  IapDebugViewController.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/11/30.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class IapDebugViewController:UIViewController{
    @IBAction func print_trans_line(_ sender: Any) {
        iap_center?.show_transaction_line()
    }
    
    @IBAction func print_trand_database(_ sender: Any) {
        iap_center?.show_transaction_database()
    }
    @IBAction func send_verify_forbidden(_ sender: Any) {
        iap_center?.switch_send_verify_forbidden()
    }
    @IBAction func receiver_verify_forbidden(_ sender: Any) {
        iap_center?.switch_receiver_verify_forbidden()
    }
    
    @IBAction func print_current_setting(_ sender: Any) {
        iap_center?.show_forbidden_setting()
    }
    
    
}




