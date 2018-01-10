//
//  PublicViewCell.swift
//  paeban_ios_beta
//
//  Created by elijah on 2018/1/8.
//  Copyright © 2018年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PublicViewCellDelegate {
    @objc optional func did_recive_alert_unlock_distance()
}

class PublicViewCell:UITableViewCell{
    var delegate:PublicViewCellDelegate?
    func unlock_distance(){
        delegate?.did_recive_alert_unlock_distance?()
    }
}
























