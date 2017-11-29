//
//  language_profile.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/11/29.
//  Copyright © 2017年 尚義 高. All rights reserved.
//  Fuck!! Copyright belong to me(elijah)!!!


import Foundation

//MARK: language profile
public enum alert_string:String {
    // 標題
    case warning = "警告"
    case confirm = "確定"
    case cancel = "取消"
    case error = "錯誤"
    case notice = "通知"
    
    // 句子
    case internet_error_do_you_want_retry = "網路錯誤，是否重試"
    case initiate_transaction = "正在啟動交易"
    case transactioning_please_try_later = "尚有交易進行中，請稍後再試"
    case trying_to_complete_last_transaction = "正在完成上一次交易"
    case exchanging_point = "正在進行點數轉換"
    case transaction_fail = "交易驗證失敗，是否重試"
    case transaction_success = "交易成功"
    case verifying = "驗證中"
}








